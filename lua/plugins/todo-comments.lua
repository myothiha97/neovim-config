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
      -- Show todos in the Trouble bottom panel (grouped by file, jump-with-<cr> keeps the
      -- panel open, toggle to close) instead of a floating picker that closes on select.
      -- This is todo-comments' own data via its built-in `Trouble todo` source; filter by the
      -- canonical tag with Trouble's `filter.tag=` syntax. Disable LazyVim's picker defaults.
      { "<leader>st", false },
      { "<leader>sT", false },
      {
        "<leader>st",
        "<cmd>Trouble todo toggle filter.tag=TODO<cr>",
        desc = "Todo list (Trouble)",
      },
      {
        "<leader>se",
        "<cmd>Trouble todo toggle filter.tag=ISSUE<cr>",
        desc = "Issues list (Trouble)",
      },
      {
        "<leader>sT",
        "<cmd>Trouble todo toggle<cr>",
        desc = "Todo all (Trouble)",
      },
    },
  },
}
