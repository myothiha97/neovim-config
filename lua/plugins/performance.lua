return {
  -- =============================================
  -- DISABLED PLUGINS (Performance optimization)
  -- =============================================

  -- Disable treesitter-context (not in default LazyVim)
  { "nvim-treesitter/nvim-treesitter-context", enabled = false },

  -- HIGH: Disable noice.nvim (intercepts all messages, major runtime impact)
  { "folke/noice.nvim", enabled = false },

  -- MEDIUM: Disable nvim-lint (use ESLint LSP only, avoids duplicate linting)
  { "mfussenegger/nvim-lint", enabled = false },

  -- MEDIUM: Disable gitsigns (heavy in large git repos)
  { "lewis6991/gitsigns.nvim", enabled = false },

  -- LOW: Disable bufferline (recalculates on every buffer change)
  { "akinsho/bufferline.nvim", enabled = false },

  -- LOW: Disable persistence/session (can cause micro-freezes on exit)
  { "folke/persistence.nvim", enabled = false },

  -- mini.pairs kept enabled (user preference)

  { "echasnovski/mini.surround", enabled = true },
  { "echasnovski/mini.ai", enabled = false },

  -- =============================================
  -- THROTTLED PLUGINS (Reduced update frequency)
  -- =============================================

  -- Throttle lualine updates (default 100ms -> 500ms)
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        refresh = {
          statusline = 500,
          tabline = 1000,
          winbar = 1000,
        },
      },
    },
  },

  -- which-key kept at default 200ms delay (user preference)

  -- =============================================
  -- COMPLETION (blink.cmp)
  -- =============================================

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
}
