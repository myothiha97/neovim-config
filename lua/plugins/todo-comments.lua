local keywords = {
  TODO = { icon = " ", alt = { "TODO", "Todo", "todo" } },
  PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE", "Perf", "perf", "Opt" } },
  REFACTOR = { icon = " ", color = "default", alt = { "Refactor", "REF", "ref", "REFACTOR" } },
  HACK = { icon = " ", color = "warning" },
  WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
  NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
  TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
  ISSUE = { icon = " ", color = "error", alt = { "ISSUE", "issue", "Issue", "bug", "Bug", "BUG" } },
}

return {
  {
    "folke/todo-comments.nvim",
    opts = {
      keywords = keywords,
    },
    keys = {
      {
        "tt",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next Todo",
      },
      {
        "tp",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Prev Todo",
      },
      -- Swap defaults: <leader>st = specific (TODO/HACK/WARN), <leader>sT = all
      { "<leader>st", false },
      { "<leader>sT", false },
      {
        "<leader>st",
        function()
          Snacks.picker.todo_comments({ keywords = { "todo", "Todo", "TODO" } })
        end,
        desc = "Todo list",
      },
      {
        "<leader>se",
        function()
          Snacks.picker.todo_comments({ keywords = { "FIX", "fix", "Fix", "Issue", "ISSUE", "issue" } })
        end,
        desc = "Issues/Fixes list",
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
