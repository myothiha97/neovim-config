return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    explorer = { enabled = false },
  },
  keys = {
    {
      "<leader>ee",
      function()
        Snacks.explorer()
      end,
      desc = "File Explorer",
    },
  },
}
