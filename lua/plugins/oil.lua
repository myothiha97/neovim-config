return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  keys = {
    { "<leader>e", "<cmd>lua require('oil').toggle_float()<CR>", desc = "Open Oil (Float)" },
  },
  lazy = false, -- let it run initially
  opts = {
    float = {
      padding = 2,
      max_width = 0,
      max_height = 0,
      border = "rounded",
      win_options = {
        winhl = "Normal:NormalFloat",
      },
    },
  },
  -- Optional dependencies
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
}
