return {
  "craftzdog/solarized-osaka.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    -- Terminal-transparent so Ghostty's `background` + `background-opacity`
    -- blend the wallpaper through. Set to false to force solid #001419.
    transparent = true,
    on_colors = function(c)
      -- c.orange = "#e03857"
      -- c.orange500 = "#e03857"

      -- yellow - #bdb020 brighter
      -- c.yellow = "#baac0d"
      -- c.yellow500 = "#baac0d"

      -- yellow -  #a3970b darker
      c.yellow = "#a3970b"
      c.yellow500 = "#a3970b"

      -- orange #ab3a4f more brighter

      -- c.orange = "#ab3a4f"
      -- c.orange500 = "#ab3a4f"

      -- orange #b83e55 similar to #ab3a4f but lighter
      -- c.orange = "#b83e55"
      -- c.orange500 = "#b83e55"

      -- c.red = c.red300
      -- c.red500 = c.red300

      -- red b83549 brighter
      -- c.orange = "#b83549"
      -- c.orange500 = "#b83549"

      -- red #ad4454 lower contrast
      -- c.orange = "#ad4454"
      -- c.orange500 = "#ad4454"

      -- red #c75b6b muted with stronger contrast
      c.orange = "#c75b6b"
      c.orange500 = "#c75b6b"

      -- red #993141 darker
      -- c.orange = "#993141"
      -- c.orange500 = "#993141"

      -- blue - #49AEF5
      -- c.blue = "#49aef5"
      -- c.blue500 = "#49aef5"

      -- blue - #4488AB lighter
      c.blue = "#4488ab"
      c.blue500 = "#4488ab"

      --  blue - #268BD2 brighter
      -- c.blue = "#268bd2"
      -- c.blue500 = "#268bd2"

      -- orange #B02669
      -- c.orange500 = "#B02669"
      -- c.orange = "#B02669"

      -- orange #bf2c47
      -- c.orange500 = "#bf2c47"
      -- c.orange = "#bf2c47"
    end,
    on_highlights = function(hl, c)
      -- Keep module keywords consistent with the custom orange accent.
      hl["@keyword.import"] = { fg = c.orange500 }

      -- Go package names, such as `main` in `package main`.
      -- hl["@module.go"] = { fg = "#fdf6e3" }
      hl["@module.go"] = { fg = "#eee8d5" }

      hl.Visual = { bg = "#3b4261" }
      hl.VisualNOS = { bg = "#3b4261" }

      -- Re-enable with a custom color (e.g. "#073642") to restore the band.
      hl.CursorLine = { bg = "NONE" }

      -- Dedicated current-row band for Oil only (CursorLine is disabled
      -- globally above). Oil windows remap CursorLine -> OilCursorLine via
      -- winhighlight, so the band returns in Oil without touching buffers.
      hl.OilCursorLine = { bg = c.base02 }

      -- Markdown headings only. The theme links the GENERIC `@markup.heading`
      -- group to `Title` (orange500 = red-orange), and `Title` is shared by help
      -- files, pickers, `:set all` output, etc. Overriding the markdown-specific
      -- `@markup.heading.{1..6}.markdown` variants recolors `.md` titles to
      -- solarized green WITHOUT touching `Title` or any other filetype's
      -- headings. render-markdown leaves heading fg to treesitter
      -- (`foregrounds = {}` in render-markdown.lua), so this is what paints them.
      for level = 1, 6 do
        hl["@markup.heading." .. level .. ".markdown"] = { fg = c.green, bold = true }
      end

      hl.BlinkCmpMenu = { fg = c.base1, bg = c.bg_float }
      hl.BlinkCmpMenuBorder = { fg = c.base02, bg = c.bg_float }
      hl.BlinkCmpMenuSelection = { fg = c.base2, bg = c.base02, bold = true }
      hl.BlinkCmpLabel = { fg = c.base1, bg = c.none }
      hl.BlinkCmpLabelMatch = { fg = c.blue300, bg = c.none }

      hl.Pmenu = { fg = c.base1, bg = c.bg_float }
      hl.PmenuSel = { fg = c.base2, bg = c.base02, bold = true }
      hl.PmenuSbar = { bg = c.bg_highlight }
      hl.PmenuThumb = { bg = c.base01 }

      hl.DiagnosticVirtualTextError = { fg = "#ff3b30", bg = c.none }
      hl.DiagnosticVirtualTextWarn = { fg = "#e0af68", bg = c.none }
      hl.DiagnosticVirtualTextInfo = { bg = c.none }
      hl.DiagnosticVirtualTextHint = { fg = "#1abc9c", bg = c.none }

      hl.Folded = { bg = "NONE" }
      hl.UfoFoldedBg = { bg = "NONE" }

      -- grug-far matched-keyword highlight. Defaults to linking DiffText,
      -- which in this theme is a near-black green band (c.green900) -> the
      -- match looks faded. Override with a vivid bg + dark fg so the matched
      -- keyword stands out clearly in the results list. Cyan (not red/yellow)
      -- is deliberately chosen so it never reads like a vim `/`/`?` search hit:
      -- Search is yellow (#b28500), IncSearch is muted rose-red (#c75b6b).
      hl.GrugFarResultsMatch = { fg = c.base04, bg = c.cyan300, bold = false }

      -- grug-far results summary ("N matches in M files"). Defaults to linking
      -- Comment, which is dim/faded against the panel -> the total is hard to
      -- read. Force the theme's lightest fg so the count is legible.
      hl.GrugFarResultsStats = { fg = c.base2 }

      -- TODO: brighten the snacks picker match highlight (currently a faded
      -- olive band). Setting `hl.SnacksPickerMatch` here does NOT take effect —
      -- something re-applies it to `DiffText` AFTER this on_highlights runs
      -- (snacks registers picker hl groups lazily on its own ColorScheme hook).
      -- Needs investigating: likely set it via a late ColorScheme autocmd or in
      -- the snacks plugin spec instead of the theme. Scope: snacks picker only.
    end,
  },
}
