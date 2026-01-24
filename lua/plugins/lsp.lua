return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = false,
      },
      servers = {
        emmet_ls = {
          filetypes = {
            "html",
            "typescriptreact",
            "javascriptreact",
            "css",
            "sass",
            "scss",
            "less",
            "eruby",
          },
        },
        eslint = {
          settings = {
            run = "onSave",
            workingDirectory = { mode = "location" },
            rulesCustomizations = {
              { rule = "*", severity = "warn" },
            },
          },
        },
      },
    },
    init = function()
      -- Custom gd to filter node_modules (only when LSP is attached)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          vim.keymap.set("n", "gd", function()
            vim.lsp.buf.definition({
              on_list = function(options)
                local items = options.items
                if #items > 1 then
                  local filtered = {}
                  for _, item in ipairs(items) do
                    if not string.match(item.filename or "", "node_modules") then
                      table.insert(filtered, item)
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
          end, { buffer = args.buf, desc = "Goto Definition (Skip node_modules)" })
        end,
      })
    end,
  },
}
