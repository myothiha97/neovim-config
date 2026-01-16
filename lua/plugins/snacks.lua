return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    explorer = { enabled = false },
    scroll = { enabled = false },
    dim = { enabled = false },
    picker = {
      layout = {
        preview = false,
        layout = {
          width = 0.3,
          height = 0.4,
        },
      },
    },
  },
  keys = {
    {
      "<leader><leader>",
      function()
        require("snacks").picker.files({ cwd = vim.fn.expand("%:p:h") })
      end,
      desc = "Find Files (current file dir)",
    },
    {
      "<leader>ff",
      function()
        require("snacks").picker.files()
      end,
      desc = "Find Files (root)",
    },
    { "<leader>e", false },
  },
}
