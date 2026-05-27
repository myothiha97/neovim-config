-- Active colorscheme registry. Imported explicitly by lua/config/lazy.lua so
-- the sibling theme files in lua/colorschemes/ stay reference-only (not
-- installed). To switch themes: change `colorscheme` below and require the
-- matching module.
return {
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "solarized-osaka" },
  },
  require("colorschemes.solarized-osaka"),
}
