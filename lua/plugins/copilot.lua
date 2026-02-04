return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = { accept = false }, -- Handling manually below
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)
      local suggestion = require("copilot.suggestion")
      local map = vim.keymap.set

      -- [ CORE REQUESTS ]
      -- Accept full suggestion
      map("i", "<C-l>", function()
        if suggestion.is_visible() then
          suggestion.accept()
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-l>", true, false, true), "n", false)
        end
      end, { desc = "Copilot: Accept" })

      -- Toggle with message
      map("n", "<leader>ad", function()
        suggestion.toggle_auto_trigger()
        local is_enabled = require("copilot.config").to_get_passed().suggestion.auto_trigger
        vim.notify(
          "Copilot: " .. (is_enabled and "Enabled" or "Disabled"),
          is_enabled and vim.log.levels.INFO or vim.log.levels.WARN
        )
      end, { desc = "Copilot: Toggle" })

      -- [ PRO ADDITIONS ]
      -- Accept only the next WORD (Alt + w)
      map("i", "<M-w>", function()
        suggestion.accept_word()
      end, { desc = "Copilot: Accept Word" })

      -- Accept only the next LINE (Alt + l)
      map("i", "<M-l>", function()
        suggestion.accept_line()
      end, { desc = "Copilot: Accept Line" })

      -- Cycle through suggestions (Alt + ] and Alt + [)
      map("i", "<M-]>", function()
        suggestion.next()
      end, { desc = "Copilot: Next Suggestion" })
      map("i", "<M-[>", function()
        suggestion.prev()
      end, { desc = "Copilot: Prev Suggestion" })
    end,
  },
}
