return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Use the special servers['*'] key to add keymaps for all LSP servers
        ["*"] = {
          keys = {
            -- Disable the default 'K' keymap for hover
            { "K", false },
            { "<c-i>", vim.lsp.buf.hover, desc = "Custom Hover Documentation" },
          },
        },
      },
    },
  },
}
