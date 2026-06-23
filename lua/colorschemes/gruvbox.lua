return {
  "ellisonleao/gruvbox.nvim",
  priority = 1000,
  opts = {
    constrast = "hard", -- Applies the hard variant or anyother of the available variants by gruvbox.nvim
    palette_overrides = {
      -- Overrides the default hard contrast background (#1d2021)
      -- with a darker shade to match VS Code
      dark0_hard = "#181818",
    },
    overrides = {
      -- Ensure the main editor and floating windows use the new dark background
      Normal = { bg = "#181818" },
      NormalFloat = { bg = "#181818" },
      SignColumn = { bg = "#181818" },
    },
  },
}
