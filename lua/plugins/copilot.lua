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
        -- Built-in guard checks vim.fn.pumvisible() which is always 0 with blink.cmp
        -- (custom popup, not pumenu). Coexistence is handled via BlinkCmp* autocmds below.
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

      -- blink.cmp coexistence: dismiss copilot ghost text while menu is open,
      -- re-request a fresh suggestion when it closes (the built-in
      -- hide_during_completion guard relies on pumvisible() and never fires for blink).
      -- TODO: need to check if below autocmds are safe for peformance
      -- vim.api.nvim_create_autocmd("User", {
      --   pattern = "BlinkCmpMenuOpen",
      --   callback = function()
      --     if suggestion.is_visible() then
      --       suggestion.dismiss()
      --     end
      --   end,
      -- })
      -- vim.api.nvim_create_autocmd("User", {
      --   pattern = "BlinkCmpMenuClose",
      --   callback = function()
      --     if vim.g.copilot_enabled == false then
      --       return
      --     end
      --     vim.schedule(function()
      --       if vim.api.nvim_get_mode().mode:match("^[iR]") and not suggestion.is_visible() then
      --         suggestion.next()
      --       end
      --     end)
      --   end,
      -- })

      -- Accept ghost text; fall through to normal behavior if not visible
      local function accept_or(key)
        return function()
          if suggestion.is_visible() then
            suggestion.accept()
          else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "n", false)
          end
        end
      end
      -- TODO: below keymap is just temporary, since we use c-l for blink completion, we need to use differnt keymap for copilot acceptance
      -- for now we use <C-o>, but i am not sure if this keymap could conflict with nvim jump to prev location function
      map("i", "<C-o>", accept_or("<C-o>"), { desc = "Copilot: Accept" })
      -- map("i", "<C-;>", accept_or("<C-;>"), { desc = "Copilot: Accept" })
      -- map("i", "<C-'>", accept_or("<C-'>"), { desc = "Copilot: Accept" })

      -- Esc: always exit insert mode; if a suggestion is visible, dismiss it first
      map("i", "<Esc>", function()
        if suggestion.is_visible() then
          suggestion.dismiss()
        end
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      end, { desc = "Copilot: Dismiss and Exit Insert" })

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

      -- Check / recover copilot status from normal mode
      map("n", "<leader>aS", "<cmd>Copilot status<cr>", { desc = "Copilot: Status" })
      map("n", "<leader>aR", "<cmd>Copilot restart<cr>", { desc = "Copilot: Restart" })
    end,
  },
}
