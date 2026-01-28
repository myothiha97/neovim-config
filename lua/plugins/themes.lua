return {
  {
    "navarasu/onedark.nvim",
    opts = {
      style = "cool",
      transparent = false,
      term_colors = true,
      highlights = {
        -- Increase visual selection contrast
        -- Visual = { bg = "#3b4261" }, -- darker/more visible selection
        -- VisualNOS = { bg = "#3b4261" },

        Visual = { bg = "#264f78" },
        VisualNOS = { bg = "#264f78" },

        -- MatchParen = { bg = "#4b5263", fg = "#e5c07b", bold = true },

        -- CursorLine = { bg = "#2d323b" },
        -- CursorLineNr = { fg = "#e5c07b", bold = true },
      },
    },

    -- uncomment below line for default load onedark
    -- config = function(_, opts)
    --   require("onedark").setup(opts)
    --   require("onedark").load()
    -- end,
  },
  -- Configure LazyVim to load tokyonight
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
  -- Configure Tokyonight to use the "night" style
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "night",
    },
  },
}
