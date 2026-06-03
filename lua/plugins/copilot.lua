return {
  {
    "zbirenbaum/copilot.lua",
    -- lazy.nvim uses `dependencies`, not packer's `requires`. copilot.lua's
    -- nes/api.lua delegates to require("copilot-lsp.nes"), so NES needs this
    -- plugin on the runtimepath before copilot.lua's setup runs.
    dependencies = { "copilotlsp-nvim/copilot-lsp" },
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
        --
        -- debounce: 300ms gives the server time to finish multi-line generations
        -- before the next keystroke cancels the in-flight request. WebStorm uses
        -- a similar window (~300-400ms). Lower if you want snappier single-token
        -- suggestions at the cost of multi-line ones.
        auto_trigger = true,
        hide_during_completion = false,
        debounce = 300,
        keymap = { accept = false },
      },
      nes = {
        enabled = true,
        auto_trigger = false,

        -- NES persistence tuning. copilot-lsp's defaults are move_count_threshold=3
        -- and distance_threshold=40 -- aggressive enough that scrolling up to check
        -- a function signature wipes the pending edit before you can accept it.
        -- Bumping both buys time to navigate context first.

        move_count_threshold = 10,
        distance_threshold = 100,
        count_horizontal_moves = false,
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

      -- <C-l>: accept current suggestion AND immediately fire a fresh request
      -- at the new cursor position. Mimics WebStorm/Zed's "chained Tab" feel
      -- where the next ghost appears right after accept without waiting for
      -- TextChangedI / debounce. We schedule the next() call so accept()'s
      -- text insertion and ctx reset complete first; otherwise next() would
      -- see the pre-accept context and cycle the old candidate list instead
      -- of fetching for the new cursor position.
      map("i", "<C-l>", function()
        if suggestion.is_visible() then
          suggestion.accept()
          vim.schedule(function()
            suggestion.next()
          end)
        end
      end, { desc = "Copilot: Accept + Trigger Next" })

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

      -- Gate NES rendering on vim.g.copilot_enabled. The TextChanged autocmd
      -- in copilot-lsp/nes/init.lua:191 captures request_nes by upvalue at
      -- LspAttach time, so we can't stop new requests post-hoc — but we can
      -- block the render. Request still flies (cheap), nothing draws.
      local nes_ui_ok, nes_ui = pcall(require, "copilot-lsp.nes.ui")
      if nes_ui_ok and not nes_ui._toggle_wrapped then
        local original_display = nes_ui._display_next_suggestion
        nes_ui._display_next_suggestion = function(bufnr, ns_id, edits)
          if not vim.g.copilot_enabled then
            return false
          end
          return original_display(bufnr, ns_id, edits)
        end
        nes_ui._toggle_wrapped = true
      end

      local function toggleCopilotSuggestions()
        suggestion.toggle_auto_trigger()
        vim.g.copilot_enabled = not vim.g.copilot_enabled
        -- Belt-and-suspenders: when disabling, drop any ghost text and any
        -- pending NES that was rendered just before the toggle. The
        -- toggle/render-gate only affects *future* draws.
        if not vim.g.copilot_enabled then
          if suggestion.is_visible() then
            suggestion.dismiss()
          end
          local nes_ok, nes = pcall(require, "copilot-lsp.nes")
          if nes_ok then
            nes.clear()
          end
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

      -- Copy "path:line" to the system clipboard. Companion to <leader>as
      -- (keymaps.lua), which copies the bare relative path — this appends the
      -- cursor line so the reference jumps straight to a location. The
      -- `path:line` form is what Claude Code CLI / LSP / most editors parse as
      -- a jump target. `:.` keeps the path cwd-relative, matching <leader>as.
      map("n", "<leader>al", function()
        local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
        local ref = path .. ":" .. vim.fn.line(".")
        vim.fn.setreg("+", ref)
        vim.notify("Copied: " .. ref, vim.log.levels.INFO)
      end, { desc = "Copy File Path + Line to Clipboard" })

      -- Visual variant: copy "path:start-end" for the selected line range.
      -- line("v") is the selection anchor, line(".") the cursor end; min/max
      -- normalizes them so direction of selection doesn't matter.
      map("v", "<leader>al", function()
        local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
        local a, b = vim.fn.line("v"), vim.fn.line(".")
        local first, last = math.min(a, b), math.max(a, b)
        local ref = first == last and (path .. ":" .. first) or (path .. ":" .. first .. "-" .. last)
        vim.fn.setreg("+", ref)
        vim.notify("Copied: " .. ref, vim.log.levels.INFO)
      end, { desc = "Copy File Path + Line Range to Clipboard" })
    end,
  },
}
