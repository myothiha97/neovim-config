return {
  {
    "MagicDuck/grug-far.nvim",
    opts = {
      headerMaxWidth = 80,
      -- UI Spacing and Clarity
      showCompactInputs = false, -- Ensures inputs aren't squashed
      showInputsTopPadding = true, -- Gap above search/replace fields
      showInputsBottomPadding = true, -- Gap below search/replace fields

      -- This adds a visual horizontal line between different files
      -- in the results, providing the "breathing room" you need.
      resultsSeparatorLineChar = "─",
    },
    keys = {
      {
        "<leader>sr",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
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
