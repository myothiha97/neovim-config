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
      -- Neovide needs transparent=false so it has a bg color to apply opacity to.
      -- In terminal (Ghostty), transparent=true lets the terminal bg show through.
      transparent = not vim.g.neovide,
      styles = {
        -- "normal" for Neovide (same bg as editor), "transparent" for terminal
        sidebars = vim.g.neovide and "normal" or "transparent",
        floats = vim.g.neovide and "normal" or "transparent",
      },
      on_highlights = function(hl)
        -- In Neovide, override tokyonight's bg (#1a1b26) to match Ghostty's bg (#1a1d24)
        if vim.g.neovide then
          local bg = "#1a1d24"
          local fg = hl.Normal and hl.Normal.fg or "#c0caf5"
          hl.Normal = { bg = bg, fg = fg }
          hl.NormalNC = { bg = bg, fg = fg }
          hl.NormalFloat = { bg = bg, fg = fg }
          hl.NormalSB = { bg = bg, fg = fg }
          hl.FloatBorder = { bg = bg, fg = "#3b4261" }
          hl.FloatTitle = { bg = bg, fg = "#7aa2f7" }
        end

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
