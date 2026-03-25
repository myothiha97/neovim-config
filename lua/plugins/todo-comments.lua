local keywords = {
  TODO = { icon = " ", alt = { "TODO", "Todo", "td", "Issue", "Bug" } },
  PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE", "Perf", "perf", "Opt" } },
  REFACTOR = { icon = " ", color = "default", alt = { "Refactor", "REF", "ref", "REFACTOR" } },
  HACK = { icon = " ", color = "warning" },
  WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
  NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
  TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
}

return {
  {
    "folke/todo-comments.nvim",
    opts = {
      keywords = keywords,
    },
    keys = {
      {
        "<leader>td",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next Todo",
      },
      -- Swap defaults: <leader>st = specific (TODO/HACK/WARN), <leader>sT = all
      { "<leader>st", false },
      { "<leader>sT", false },
      {
        "<leader>st",
        function()
          Snacks.picker.todo_comments({ keywords = { "TODO", "FIX" } })
        end,
        desc = "Todo/Fix/Fixme",
      },
      {
        "<leader>sT",
        function()
          Snacks.picker.todo_comments({ keywords = vim.tbl_keys(keywords) })
        end,
        desc = "Todo (all)",
      },
    },
  },
}
