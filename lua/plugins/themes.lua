return {
  {
    "navarasu/onedark.nvim",
    opts = {
      style = "cool",
      -- colors = {
      --   bg0 = "#1a1b26",
      -- },
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
      transparent = true,
      styles = {
        -- sidebars = "dark",
        -- floats = "dark",
        sidebars = "transparent",
        floats = "transparent",
      },
      on_highlights = function(hl)
        -- Sync relative line number color with Ghostty green (#02b890)
        hl.CursorLineNr = { fg = "#02b890", bold = true }

        -- Intensify UI elements
        hl.Visual = { bg = "#264f78" }
        hl.LineNr = { fg = "#5b6268" }
        -- Reduce CursorLine intensity by 40% (blend toward bg)
        hl.CursorLine = { bg = "#212434" }

        -- Reduce Folded highlight intensity by 50% (blend toward bg)
        hl.Folded = { bg = "#21283f" }

        -- Make unused vars/imports visible (default is nearly black)
        hl.DiagnosticUnnecessary = { fg = "#737aa2", italic = true }
      end,
    },
  },
}
