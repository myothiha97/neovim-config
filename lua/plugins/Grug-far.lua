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
          grug.open({
            prefills = {
              filesFilter = (ext and ext ~= "") and ("*." .. ext) or nil,
            },
          })
        end,
        mode = { "n", "x" },
        desc = "Search and Replace (Grug-far)",
      },
    },
  },
}
