return {
  {
    "monkoose/neocodeium",
    enabled = false,
    event = "InsertEnter",
    cmd = "NeoCodeium",
    opts = {
      debounce = true,
      max_lines = 10000,
      filter = function()
        -- hide suggestions when blink.cmp menu is open
        local ok, blink = pcall(require, "blink.cmp")
        return not (ok and blink.is_visible())
      end,
      filetypes = {
        help = false,
        gitcommit = false,
        gitrebase = false,
        ["."] = false,
      },
    },
    config = function(_, opts)
      local neocodeium = require("neocodeium")
      neocodeium.setup(opts)

      -- clear suggestions when blink menu opens
      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuOpen",
        callback = function()
          neocodeium.clear()
        end,
      })

      local map = vim.keymap.set

      -- Accept full suggestion (same keys as copilot)
      local function accept_or_fallback(fallback_key)
        if neocodeium.visible() then
          neocodeium.accept()
        else
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(fallback_key, true, false, true), "n", false)
        end
      end
      map("i", "<C-l>", function() accept_or_fallback("<C-l>") end, { desc = "Neocodeium: Accept" })
      map("i", "<C-;>", function() accept_or_fallback("<C-;>") end, { desc = "Neocodeium: Accept" })
      map("i", "<C-'>", function() accept_or_fallback("<C-'>") end, { desc = "Neocodeium: Accept" })

      -- Accept word / line
      map("i", "<M-w>", function() neocodeium.accept_word() end, { desc = "Neocodeium: Accept Word" })
      map("i", "<M-l>", function() neocodeium.accept_line() end, { desc = "Neocodeium: Accept Line" })

      -- Cycle suggestions
      map("i", "<M-]>", function() neocodeium.cycle(1) end,  { desc = "Neocodeium: Next Suggestion" })
      map("i", "<M-[>", function() neocodeium.cycle(-1) end, { desc = "Neocodeium: Prev Suggestion" })

      -- Toggle
      map("n", "<leader>ad", function()
        vim.cmd("NeoCodeium toggle")
      end, { desc = "Neocodeium: Toggle Suggestions" })
    end,
  },
}
