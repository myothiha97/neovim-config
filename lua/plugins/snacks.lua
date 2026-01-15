return {
  "folke/snacks.nvim",
  opts = {
    explorer = { enabled = false },
    scroll = { enabled = false },
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
