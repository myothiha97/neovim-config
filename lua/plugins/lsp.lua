local debounce_text_change = 300

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },
      -- Performance: Don't update diagnostics in insert mode
      diagnostics = {
        update_in_insert = false,
        severity_sort = true,
      },
      servers = {
        -- Free <C-k> in insert mode for our Copilot toggle.
        -- LazyVim binds it to vim.lsp.buf.signature_help via servers["*"].keys
        -- (see lazy/LazyVim/lua/lazyvim/plugins/lsp/init.lua:87).
        -- opts_extend = { "servers.*.keys" } appends this to LazyVim's defaults,
        -- and Keys.resolve drops entries whose rhs is false.
        ["*"] = {
          keys = {
            { "<c-k>", false, mode = "i" },
            { "<leader>cc", false, mode = { "n", "x" } },
            { "<leader>cC", false, mode = "n" },
          },
        },
        -- Disable nvim-lspconfig's stock copilot config so mason-lspconfig's automatic_enable
        -- skips it. Otherwise it auto-starts the binary copilot-language-server and fights
        -- with the zbirenbaum/copilot.lua plugin for the "copilot" client slot — the plugin's
        -- per-buffer state never initializes and ghost text never renders.
        copilot = { enabled = false },
        emmet_ls = {
          -- Only HTML/CSS - TSX/JSX use custom snippets for tag completion
          filetypes = {
            "html",
            -- "css",
            -- "sass",
            -- "scss",
            -- "less",
          },
          flags = {
            debounce_text_changes = debounce_text_change,
          },
        },
        -- ESLint disabled - TypeScript alone is sufficient for current project
        -- Re-enable by setting enabled = true when needed
        eslint = {
          enabled = false,
          settings = {
            run = "onSave",
            workingDirectory = { mode = "location" },
            rulesCustomizations = {
              { rule = "*", severity = "warn" },
            },
          },
          flags = {
            debounce_text_changes = debounce_text_change,
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              codeLens = {
                enable = false,
              },
            },
          },
        },
        -- TypeScript LSP optimization (React/TSX focused)
        vtsls = {
          flags = {
            debounce_text_changes = debounce_text_change,
          },
          settings = {
            typescript = {
              suggest = {
                completeFunctionCalls = false,
              },
              preferences = {
                -- Don't scan package.json for auto-imports (big perf win for large React projects)
                includePackageJsonAutoImports = "off",
              },
              tsserver = {
                -- Give tsserver more heap (default is ~3GB, React projects can need more)
                maxTsServerMemory = 3072,
                -- Don't watch node_modules for changes
                watchOptions = {
                  watchFile = "useFsEvents",
                  watchDirectory = "useFsEvents",
                  fallbackPolling = "dynamicPriority",
                  synchronousWatchDirectory = true,
                  excludeDirectories = { "**/node_modules", "**/.git" },
                },
              },
            },
            javascript = {
              suggest = {
                completeFunctionCalls = false,
              },
              preferences = {
                includePackageJsonAutoImports = "off",
              },
            },
          },
        },
      },
    },
    init = function()
      -- Neovim 0.12 added vim.lsp.document_color with its own internal LspAttach autocmd
      -- that fires before any plugin-registered handler. Overriding the handler or clearing
      -- colorProvider in LspAttach is too late — the module is already polling. Replacing
      -- enable() here (before any client attaches) stops it from ever activating.
      if vim.lsp.document_color then
        vim.lsp.document_color.enable = function() end
      end

      -- Disable semantic tokens globally: stops LSP from computing/sending token payloads.
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client then
            client.server_capabilities.semanticTokensProvider = nil
          end
        end,
      })

      -- Restart LSP to refresh type diagnostics after external file changes (e.g., Grug-far)
      vim.keymap.set("n", "<leader>cL", function()
        local clients = vim.lsp.get_clients()
        for _, client in ipairs(clients) do
          client.stop()
        end
        vim.notify("LSP stopped, restarting...", vim.log.levels.INFO)
        vim.defer_fn(function()
          vim.cmd("edit!")
          vim.notify("LSP restarted", vim.log.levels.INFO)
        end, 100)
      end, { noremap = true, silent = false, desc = "Restart LSP" })

      -- Custom gd to filter node_modules (only when LSP is attached)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          -- vim.schedule ensures this runs AFTER LazyVim's LspAttach keymaps
          vim.schedule(function()
              vim.keymap.set("n", "gd", function()
              vim.lsp.buf.definition({
                on_list = function(options)
                  local items = options.items
                  if #items > 1 then
                    local filtered = {}
                    -- Filter 1: Remove node_modules
                    for _, item in ipairs(items) do
                      if not string.match(item.filename or "", "node_modules") then
                        table.insert(filtered, item)
                      end
                    end

                    -- Filter 2: If multiple items remain, remove the current file (to skip imports)
                    if #filtered > 1 then
                      local current_file = vim.api.nvim_buf_get_name(0)
                      local external_defs = {}
                      for _, item in ipairs(filtered) do
                        if item.filename ~= current_file then
                          table.insert(external_defs, item)
                        end
                      end

                      -- Only apply this filter if we found an external definition
                      -- (Prevents breaking gd if the definition IS in the current file)
                      if #external_defs > 0 then
                        filtered = external_defs
                      end
                    end

                    if #filtered > 0 then
                      items = filtered
                    end
                  end

                  if #items == 1 then
                    local item = items[1]
                    vim.cmd("edit " .. vim.fn.fnameescape(item.filename))
                    vim.schedule(function()
                      local lnum = item.lnum or 1
                      local col = (item.col or 1) - 1
                      local line_count = vim.api.nvim_buf_line_count(0)
                      if lnum > line_count then
                        lnum = line_count
                      end
                      vim.api.nvim_win_set_cursor(0, { lnum, math.max(0, col) })
                    end)
                  else
                    vim.fn.setqflist({}, " ", { title = "LSP Definitions", items = items })
                    vim.cmd("copen")
                  end
                end,
              })
            end, { buffer = args.buf, desc = "Goto Definition (Skip node_modules & imports)" })
          end)
        end,
      })
    end,
  },
}
