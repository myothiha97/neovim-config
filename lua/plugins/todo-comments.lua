return {
  {
    "folke/todo-comments.nvim",
    opts = {
      keywords = {
        todo = { alt = { "todo" } },
      },
    },
    keys = {
      {
        "tt",
        function()
          require("todo-comments").jump_next()
          --
        end,
        desc = "Next Todo",
      },
      {
        "tp",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Previous Todo",
      },
    },
  },
}
