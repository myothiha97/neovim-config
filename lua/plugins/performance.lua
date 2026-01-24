return {
  -- Disable treesitter-context (not in default LazyVim)
  { "nvim-treesitter/nvim-treesitter-context", enabled = false },
  {
    "saghen/blink.cmp",
    enabled = true,
    opts = {
      keymap = {
        -- Disable Tab for signature help, make it just insert tab/indent
        ["<Tab>"] = {},
        ["<S-Tab>"] = {},
      },
      completion = {
        -- Disable ghost text preview in the editor
        ghost_text = { enabled = false },
      },
      sources = {
        -- Prioritize LSP over snippets
        providers = {
          lsp = { score_offset = 100 }, -- Higher = shown first
          snippets = { score_offset = -50 }, -- Lower = shown later
        },
      },
    },
  },
  { "echasnovski/mini.surround", enabled = true },
  { "echasnovski/mini.ai", enabled = false },
}
