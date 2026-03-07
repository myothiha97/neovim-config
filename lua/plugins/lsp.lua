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
            debounce_text_changes = 100,
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
            debounce_text_changes = 100,
          },
        },
        -- TypeScript LSP optimization
        vtsls = {
          flags = {
            debounce_text_changes = 100,
          },
          settings = {
            typescript = {
              suggest = {
                completeFunctionCalls = false,
              },
            },
            javascript = {
              suggest = {
                completeFunctionCalls = false,
              },
            },
          },
        },
      },
    },
    init = function()
      -- Custom gd to filter node_modules (only when LSP is attached)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          -- vim.schedule ensures this runs AFTER LazyVim's LspAttach keymaps
          vim.schedule(function()
            -- vim.keymap.set("n", "gd", function()
            --   vim.lsp.buf.definition({
            --     on_list = function(options)
            --       local items = options.items
            --       if #items > 1 then
            --         local filtered = {}
            --         for _, item in ipairs(items) do
            --           if not string.match(item.filename or "", "node_modules") then
            --             table.insert(filtered, item)
            --           end
            --         end
            --         if #filtered > 0 then
            --           items = filtered
            --         end
            --       end
            --
            --       if #items == 1 then
            --         local item = items[1]
            --         vim.cmd("edit " .. vim.fn.fnameescape(item.filename))
            --         vim.schedule(function()
            --           local lnum = item.lnum or 1
            --           local col = (item.col or 1) - 1
            --           local line_count = vim.api.nvim_buf_line_count(0)
            --           if lnum > line_count then
            --             lnum = line_count
            --           end
            --           vim.api.nvim_win_set_cursor(0, { lnum, math.max(0, col) })
            --         end)
            --       else
            --         vim.fn.setqflist({}, " ", { title = "LSP Definitions", items = items })
            --         vim.cmd("copen")
            --       end
            --     end,
            --   })
            --
            --
            -- end, { buffer = args.buf, desc = "Goto Definition (Skip node_modules)" })
            --
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
