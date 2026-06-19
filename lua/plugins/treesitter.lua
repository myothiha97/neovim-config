return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    opts = function(_, opts)
      opts.select = opts.select or {}
      opts.select.lookahead = true
      -- Free ]c/[c for gitsigns hunk navigation (see plugins/git.lua). These were
      -- LazyVim's treesitter class-start moves; class nav is rarely used now, so we
      -- drop just the start keys ([C/]C class-end moves are left intact).
      if opts.move and opts.move.keys then
        if opts.move.keys.goto_next_start then
          opts.move.keys.goto_next_start["]c"] = nil
        end
        if opts.move.keys.goto_previous_start then
          opts.move.keys.goto_previous_start["[c"] = nil
        end
      end
    end,
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
