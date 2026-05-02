return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    opts = {
      select = { lookahead = true },
    },
    init = function()
      local function sel(query)
        return function()
          require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
        end
      end
      vim.keymap.set({ "x", "o" }, "af", sel("@function.outer"), { desc = "Around function" })
      vim.keymap.set({ "x", "o" }, "if", sel("@function.inner"), { desc = "Inside function" })
      vim.keymap.set({ "x", "o" }, "ac", sel("@class.outer"), { desc = "Around class" })
      vim.keymap.set({ "x", "o" }, "ic", sel("@class.inner"), { desc = "Inside class" })
      vim.keymap.set({ "x", "o" }, "ai", sel("@class.outer"), { desc = "Around interface/object" })
      vim.keymap.set({ "x", "o" }, "ii", sel("@class.inner"), { desc = "Inside interface/object" })
      vim.keymap.set({ "x", "o" }, "aa", sel("@parameter.outer"), { desc = "Around parameter" })
      vim.keymap.set({ "x", "o" }, "ia", sel("@parameter.inner"), { desc = "Inside parameter" })
      vim.keymap.set({ "x", "o" }, "ax", sel("@call.outer"), { desc = "Around call" })
      vim.keymap.set({ "x", "o" }, "ix", sel("@call.inner"), { desc = "Inside call" })
    end,
  },
}
