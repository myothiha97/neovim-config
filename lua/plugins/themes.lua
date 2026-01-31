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
      transparent = false,
      styles = {
        sidebars = "dark",
        floats = "dark",
      },
      -- Increase color intensity and sync relative line numbers
      on_colors = function(colors)
        colors.bg_visual = "#264f78" -- One Dark style punchy selection
        colors.git.ignore = "#545c7e" -- Make ignored files slightly more visible
      end,

      on_highlights = function(hl)
        -- Sync relative line number color with Ghostty green (#02b890)
        hl.CursorLineNr = { fg = "#02b890", bold = true }

        -- hl.YankHighlight = { bg = "#02b890", fg = "#000000" }
        -- Make comments slightly more legible (less "soft")
        -- hl.Comment = { fg = "#737aa2", italic = true }
        -- Intensify UI elements
        hl.Visual = { bg = "#264f78" }
        hl.LineNr = { fg = "#5b6268" }
        -- Reduce CursorLine intensity by 40% (blend toward bg)
        hl.CursorLine = { bg = "#212434" }

        -- Reduce Folded highlight intensity by 50% (blend toward bg)
        hl.Folded = { bg = "#21283f" }
      end,
    },
  },
}
