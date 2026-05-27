return {
  "folke/tokyonight.nvim",
  lazy = true,
  opts = {
    style = "night",
    -- Neovide needs transparent=false so it has a bg color to apply opacity to.
    -- In terminal (Ghostty), transparent=true lets the terminal bg show through.
    transparent = false,
    styles = {
      sidebars = "normal",
      floats = "normal",
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

      hl.Visual = { bg = "#264f78" }
      hl.LineNr = { fg = "#5b6268" }
      hl.CursorLine = { bg = "NONE" }
      hl.Folded = { bg = "NONE" }
      hl.UfoFoldedBg = { bg = "NONE" }

      -- Make unused vars/imports visible (default is nearly black)
      hl.DiagnosticUnnecessary = { fg = "#737aa2", italic = true }
    end,
  },
}
