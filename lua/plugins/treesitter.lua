return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    opts = {
      select = {
        enable = true,
        lookahead = true,
      },
    },
    keys = {
      { "af", function() require("nvim-treesitter-textobjects.select").select_textobject("@function.outer") end, mode = { "x", "o" }, desc = "Around function" },
      { "if", function() require("nvim-treesitter-textobjects.select").select_textobject("@function.inner") end, mode = { "x", "o" }, desc = "Inside function" },
      { "ac", function() require("nvim-treesitter-textobjects.select").select_textobject("@class.outer") end, mode = { "x", "o" }, desc = "Around class" },
      { "ic", function() require("nvim-treesitter-textobjects.select").select_textobject("@class.inner") end, mode = { "x", "o" }, desc = "Inside class" },
      { "aa", function() require("nvim-treesitter-textobjects.select").select_textobject("@parameter.outer") end, mode = { "x", "o" }, desc = "Around parameter" },
      { "ia", function() require("nvim-treesitter-textobjects.select").select_textobject("@parameter.inner") end, mode = { "x", "o" }, desc = "Inside parameter" },
      { "ax", function() require("nvim-treesitter-textobjects.select").select_textobject("@call.outer") end, mode = { "x", "o" }, desc = "Around call" },
      { "ix", function() require("nvim-treesitter-textobjects.select").select_textobject("@call.inner") end, mode = { "x", "o" }, desc = "Inside call" },
    },
  },
}
