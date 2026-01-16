return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    explorer = { enabled = false },
    scroll = { enabled = false },
    dim = {
      enabled = false,
      -- This is the key: it dims non-focused windows
      -- Ensure no other filters are blocking Oil
    },
  },
  keys = {
    { "<leader>e", false },
  },
}
