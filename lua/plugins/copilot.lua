return {
  {
    "zbirenbaum/copilot.lua",
    enabled = true,
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = false,
        debounce = 75, -- Balance between speed and performance
        keymap = { accept = false }, -- Handling manually below
      },
      filetypes = {
        ["*"] = true, -- Enable for all filetypes
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)
      local suggestion = require("copilot.suggestion")
      local map = vim.keymap.set

      -- Accept full suggestion (Ctrl+l, Ctrl+;, Ctrl+')
      local function accept_or_fallback()
        if suggestion.is_visible() then
          suggestion.accept()
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-l>", true, false, true), "n", false)
        end
      end
      map("i", "<C-l>", accept_or_fallback, { desc = "Copilot: Accept" })
      map("i", "<C-;>", accept_or_fallback, { desc = "Copilot: Accept" })
      map("i", "<C-'>", accept_or_fallback, { desc = "Copilot: Accept" })

      -- Toggle auto-trigger
      vim.g.copilot_enabled = true
      map("n", "<leader>ad", function()
        suggestion.toggle_auto_trigger()
        vim.g.copilot_enabled = not vim.g.copilot_enabled
        local status = vim.g.copilot_enabled and "Enabled" or "Disabled"
        local level = vim.g.copilot_enabled and vim.log.levels.INFO or vim.log.levels.WARN
        vim.notify("Copilot Autocomplete: " .. status, level, { title = "Copilot" })
      end, { desc = "Copilot: Toggle Suggestions" })

      -- Accept word / line
      map("i", "<M-w>", function()
        suggestion.accept_word()
      end, { desc = "Copilot: Accept Word" })
      map("i", "<M-l>", function()
        suggestion.accept_line()
      end, { desc = "Copilot: Accept Line" })

      -- Cycle suggestions
      map("i", "<M-]>", function()
        suggestion.next()
      end, { desc = "Copilot: Next Suggestion" })
      map("i", "<M-[>", function()
        suggestion.prev()
      end, { desc = "Copilot: Prev Suggestion" })
    end,
  },
}
