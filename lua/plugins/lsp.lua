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
            -- Force the server to look for the nearest package.json
            workingDirectory = { mode = "location" },
            ocamllsp = {
              codelens = {
                enable = true,
              },
            },
          },
          -- Force the root directory to be where your config is
          root_dir = require("lspconfig.util").root_pattern(".eslintrc", ".eslintrc.json", "package.json"),
        },
        ["*"] = {
          keys = {
            -- Disable the default 'K' keymap for hover
            { "K", false },
            { "<c-i>", vim.lsp.buf.hover, desc = "Custom Hover Documentation" },
            -- Custom Go to Definition to filter out node_modules
            {
              "gd",
              function()
                vim.lsp.buf.definition({
                  on_list = function(options)
                    local items = options.items
                    if #items > 1 then
                      local filtered = {}
                      for _, item in ipairs(items) do
                        -- Only keep items that do NOT contain node_modules in the filename
                        if not string.match(item.filename, "node_modules") then
                          table.insert(filtered, item)
                        end
                      end
                      if #filtered > 0 then
                        items = filtered
                      end
                    end

                    if #items == 1 then
                      -- vim.lsp.util.jump_to_location(items[1], "utf-8")
                      vim.lsp.util.show_document(items[1].user_data, "utf-8", { focus = true })
                    else
                      -- Use the default picker (telescope/qf) if multiple results remain
                      vim.fn.setqflist({}, " ", { title = "LSP Definitions", items = items })
                      vim.cmd("copen")
                    end
                  end,
                })
              end,
              desc = "Goto Definition (Skip node_modules)",
            },
          },
        },
      },
    },
  },
}
