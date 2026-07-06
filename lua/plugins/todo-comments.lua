local keywords = {
  -- Two distinct keywords on purpose. Matching is case-sensitive (highlight.lua uses `\C`),
  -- so `TODO:` and `todo:` resolve to separate tags and can be filtered independently:
  --   TODO -> teammates' shouty uppercase comments, kept OUT of <leader>st
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
      -- Show todos in the Trouble bottom panel (grouped by file, jump-with-<cr> keeps the
      -- panel open, toggle to close) instead of a floating picker that closes on select.
      -- This is todo-comments' own data via its built-in `Trouble todo` source; filter by the
      -- canonical tag with Trouble's `filter.tag=` syntax. Tags are case-sensitive here (see the
      -- keywords table above), so `filter.tag=todo` lists only your personal lowercase `todo:`
      -- markers and never teammates' uppercase `TODO:`. `sT` (no filter) still shows everything.
      -- Disable LazyVim's picker defaults.
      { "<leader>st", false },
      { "<leader>sT", false },
      {
        "<leader>st",
        "<cmd>Trouble todo toggle filter.tag=todo<cr>",
        desc = "Todo list (Trouble)",
      },
      {
        "<leader>se",
        "<cmd>Trouble todo toggle filter.tag=issue<cr>",
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
