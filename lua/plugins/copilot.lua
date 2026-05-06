return {
  {
    "zbirenbaum/copilot.lua",
    enabled = true,
    cmd = "Copilot",
    event = { "InsertEnter" },
    opts = {
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        -- Auto-suggest alongside blink.cmp. hide_during_completion = false lets
        -- copilot's ghost text render even while blink's menu is open, so both
        -- engines stay visible. Accept keys are split: <C-l> = blink, <C-o> = copilot.
        auto_trigger = true,
        hide_during_completion = false,
        debounce = 75,
        keymap = { accept = false },
      },
      nes = {
        enabled = false,
        auto_trigger = true,
        keymap = {
          accept_and_goto = "<Tab>",
          accept = false,
          dismiss = "<Esc>",
        },
      },
      filetypes = {
        ["*"] = true, -- Enable for all filetypes
      },
    },
    config = function(_, opts)
      require("copilot").setup(opts)

      -- Fidget notifications for copilot LSP connect / disconnect
      local copilot_ready_shown = false
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          if copilot_ready_shown then
            return
          end
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "copilot" then
            copilot_ready_shown = true
            vim.schedule(function()
              local ok, fidget = pcall(require, "fidget")
              if ok then
                fidget.notify(" Copilot ready", vim.log.levels.INFO, { ttl = 3 })
              end
            end)
          end
        end,
      })
      vim.api.nvim_create_autocmd("LspDetach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "copilot" then
            copilot_ready_shown = false
            local ok, fidget = pcall(require, "fidget")
            if ok then
              fidget.notify("⚠ Copilot disconnected", vim.log.levels.WARN, { ttl = 4 })
            end
          end
        end,
      })

      -- Match neocodeium's ghost text style (#808080 medium gray)
      vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#808080", ctermfg = 244 })
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#808080", ctermfg = 244 })
        end,
      })

      local suggestion = require("copilot.suggestion")
      local map = vim.keymap.set

      -- Dismiss ghost text immediately when leaving insert mode
      vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
          if suggestion.is_visible() then
            suggestion.dismiss()
          end
        end,
      })

      -- blink.cmp coexistence: copilot's built-in hide_during_completion guard
      -- relies on pumvisible() and never fires for blink's custom floating window.
      -- Setting vim.b.copilot_suggestion_hidden makes copilot's render-time guard
      -- (suggestion/init.lua:257) drop both the current ghost and any in-flight
      -- LSP response that arrives after the menu opens.
      -- vim.api.nvim_create_autocmd("User", {
      --   pattern = "BlinkCmpMenuOpen",
      --   callback = function()
      --     vim.b.copilot_suggestion_hidden = true
      --     if suggestion.is_visible() then
      --       suggestion.dismiss()
      --     end
      --   end,
      -- })
      -- vim.api.nvim_create_autocmd("User", {
      --   pattern = "BlinkCmpMenuClose",
      --   callback = function()
      --     vim.b.copilot_suggestion_hidden = false
      --   end,
      -- })

      -- <C-o>: dedicated copilot accept. blink owns <C-l>; copilot owns <C-o>,
      -- so both engines can show suggestions simultaneously without a shared
      -- accept key. Works for both manual (<C-j>) and auto-triggered ghosts.
      map("i", "<C-o>", function()
        if suggestion.is_visible() then
          suggestion.accept()
        end
      end, { desc = "Copilot: Accept suggestion" })

      -- Esc: always exit insert mode; if a suggestion is visible, dismiss it first
      map("i", "<Esc>", function()
        if suggestion.is_visible() then
          suggestion.dismiss()
        end
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      end, { desc = "Copilot: Dismiss and Exit Insert" })

      -- Manual copilot trigger: closes blink menu if open, clears the hidden
      -- guard set by BlinkCmpMenuOpen, then requests/cycles a suggestion.
      -- Press repeatedly to cycle through variants (same as <M-]>).
      map("i", "<C-j>", function()
        local ok, blink = pcall(require, "blink.cmp")
        if ok and blink.is_menu_visible and blink.is_menu_visible() then
          blink.hide()
        end
        vim.b.copilot_suggestion_hidden = false
        suggestion.next()
      end, { desc = "Copilot: Trigger / cycle suggestion" })

      -- Toggle auto-trigger only (Copilot LSP stays loaded so manual <C-j> and
      -- blink.cmp coexistence keep working). vim.g.copilot_enabled mirrors the
      -- auto-trigger state and drives the lualine indicator color.
      vim.g.copilot_enabled = true

      local function toggleCopilotSuggestions()
        suggestion.toggle_auto_trigger()
        vim.g.copilot_enabled = not vim.g.copilot_enabled
        -- Belt-and-suspenders: when disabling, drop any ghost text that was
        -- rendered just before the toggle. toggle_auto_trigger only stops
        -- *future* requests; the current ghost can linger until next render.
        if not vim.g.copilot_enabled and suggestion.is_visible() then
          suggestion.dismiss()
        end
        local status = vim.g.copilot_enabled and "Enabled" or "Disabled"
        local level = vim.g.copilot_enabled and vim.log.levels.INFO or vim.log.levels.WARN
        vim.notify("Copilot Autocomplete: " .. status, level, { title = "Copilot" })
        vim.cmd.redrawstatus()
      end

      map("n", "<leader>ad", toggleCopilotSuggestions, { desc = "Copilot: Toggle Suggestions" })
      map("i", "<C-k>", toggleCopilotSuggestions, { desc = "Copilot: Toggle Suggestions" })

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

      -- Check / recover copilot status from normal mode
      map("n", "<leader>aS", "<cmd>Copilot status<cr>", { desc = "Copilot: Status" })
      map("n", "<leader>aR", "<cmd>Copilot restart<cr>", { desc = "Copilot: Restart" })
    end,
  },
}
