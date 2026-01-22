return {
  -- Disable treesitter-context (not in default LazyVim)
  { "nvim-treesitter/nvim-treesitter-context", enabled = true },
  {
    "saghen/blink.cmp",
    enabled = true,
    opts = {
      keymap = {
        -- Disable Tab for signature help, make it just insert tab/indent
        ["<Tab>"] = {},
        ["<S-Tab>"] = {},
      },
    },
  },
  { "echasnovski/mini.surround", enabled = true },
  { "echasnovski/mini.ai", enabled = false },
}
