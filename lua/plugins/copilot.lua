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
        -- Master switch model: when Copilot is enabled (toggled on via <leader>ad / <C-k>),
        -- auto-fire ghost text; when disabled, the LSP is detached so suggestions never run.
        -- blink.cmp coexistence is handled by BlinkCmpMenu* autocmds below.
        auto_trigger = true,
        -- hide_during_completion checks pumvisible() which never fires for blink's
        -- custom popup. Defense-in-depth still handled via BlinkCmp* autocmds below.
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

      -- Master-switch state: vim.g.copilot_enabled is the single source of truth
      -- for both LSP attach state and auto-suggestion ghost text. Default OFF.
      vim.g.copilot_enabled = false

      -- During startup we let copilot attach (so its commands are registered),
      -- then immediately detach to land in OFF state. startup_settled gates the
      -- spurious "ready" / "disconnected" toasts that fire during this dance.
      local startup_settled = false
      local copilot_ready_shown = false

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          if copilot_ready_shown then
            return
          end
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "copilot" then
            copilot_ready_shown = true
            if not startup_settled then
              return
            end
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
            if not startup_settled then
              return
            end
            local ok, fidget = pcall(require, "fidget")
            if ok then
              fidget.notify("⚠ Copilot disconnected", vim.log.levels.WARN, { ttl = 4 })
            end
          end
        end,
      })

      -- Apply the default-OFF state on the next tick (after copilot's initial
      -- attach completes). Two-step schedule ensures startup_settled flips only
      -- after the detach has fired and its event has propagated.
      vim.schedule(function()
        vim.cmd("Copilot disable")
        vim.schedule(function()
          startup_settled = true
          vim.cmd.redrawstatus()
        end)
      end)

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
      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuOpen",
        callback = function()
          vim.b.copilot_suggestion_hidden = true
          if suggestion.is_visible() then
            suggestion.dismiss()
          end
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        pattern = "BlinkCmpMenuClose",
        callback = function()
          vim.b.copilot_suggestion_hidden = false
        end,
      })

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
      -- Shared <C-l>: blink.cmp's keymap runs `select_and_accept` first, then
      -- `fallback` invokes this mapping. So menu open -> blink accepts; menu
      -- closed + ghost visible -> copilot accepts; neither -> no-op.
      map("i", "<C-l>", accept_or("<C-l>"), { desc = "Copilot: Accept (fallback from blink.cmp)" })

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

      -- Master toggle: flips Copilot LSP (attach/detach) and auto-suggestions
      -- together. vim.g.copilot_enabled drives the lualine indicator color.
      local function toggleCopilot()
        vim.g.copilot_enabled = not vim.g.copilot_enabled
        if vim.g.copilot_enabled then
          vim.cmd("Copilot enable")
        else
          vim.cmd("Copilot disable")
        end
        local status = vim.g.copilot_enabled and "Enabled" or "Disabled"
        local level = vim.g.copilot_enabled and vim.log.levels.INFO or vim.log.levels.WARN
        vim.notify("Copilot: " .. status, level, { title = "Copilot" })
        vim.cmd.redrawstatus()
      end

      map("n", "<leader>ad", toggleCopilot, { desc = "Copilot: Toggle (LSP + suggestions)" })
      map("i", "<C-k>", toggleCopilot, { desc = "Copilot: Toggle (LSP + suggestions)" })

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
