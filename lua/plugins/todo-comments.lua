local keywords = {
  -- Two distinct keywords on purpose. Matching is case-sensitive (highlight.lua uses `\C`),
  -- so `TODO:` and `todo:` resolve to separate tags and can be filtered independently:
  --   TODO -> teammates' shouty uppercase comments, listed by <leader>sT
  --   todo -> your own personal marker, this is what <leader>st lists
  TODO = { icon = " ", color = "hint" },
  todo = { icon = " ", color = "info", alt = { "Todo" } },
  PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE", "Perf", "perf", "Opt" } },
  REFACTOR = { icon = " ", color = "default", alt = { "Refactor", "REF", "ref", "REFACTOR" } },
  HACK = { icon = " ", color = "warning" },
  WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
  NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
  TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
  -- Same split rationale as TODO/todo above: uppercase = teammates (kept out of <leader>se),
  -- lowercase/titlecase = your own, which is what <leader>se lists.
  --   ISSUE / BUG -> teammates' shouty comments
  --   issue / bug -> your own personal markers, listed by <leader>se
  ISSUE = { icon = " ", color = "error", alt = { "BUG" } },
  issue = { icon = " ", color = "error", alt = { "Issue", "bug", "Bug" } },
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
      -- Use todo-comments' native location-list integration instead of a floating picker.
      -- The list opens in a bottom split and stays open after <cr>, so multiple items can be
      -- visited without reopening it. A location list keeps these results separate from the
      -- normal quickfix list on <leader>cc. Keyword filters are case-sensitive.
      -- Disable LazyVim's picker defaults first.
      { "<leader>st", false },
      { "<leader>sT", false },
      {
        "<leader>st",
        "<cmd>TodoLocList keywords=todo<cr>",
        desc = "Personal todos",
      },
      {
        "<leader>se",
        "<cmd>TodoLocList keywords=issue<cr>",
        desc = "Personal issues",
      },
      {
        "<leader>sT",
        "<cmd>TodoLocList keywords=TODO<cr>",
        desc = "Team todos",
      },
    },
  },
}
