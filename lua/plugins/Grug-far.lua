return {
  {
    "MagicDuck/grug-far.nvim",
    opts = {
      headerMaxWidth = 80,
    },
    keys = {
      {
        "<leader>sr",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          local ext_groups = {
            ts = "*.{ts,tsx}",
            tsx = "*.{ts,tsx}",
            js = "*.{js,jsx}",
            jsx = "*.{js,jsx}",
          }
          local filter = ext_groups[ext] or ((ext and ext ~= "") and ("*." .. ext) or nil)
          grug.open({
            prefills = {
              filesFilter = filter,
              flags = "--ignore-case --sort=path",
            },
          })
        end,
        mode = { "n", "x" },
        desc = "Search and Replace (Grug-far)",
      },
      {
        "<leader>sf",
        function()
          local grug = require("grug-far")
          local path = vim.fn.expand("%:p")
          if path == "" then
            return
          end
          grug.open({
            prefills = {
              filesFilter = vim.fn.expand("%:t"),
              paths = vim.fn.expand("%:h"),
              flags = "--ignore-case --sort=path",
            },
          })
        end,
        mode = { "n", "x" },
        desc = "Search and Replace in Current File (Grug-far)",
      },
    },
  },
}
