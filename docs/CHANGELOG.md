# Neovim Config Changelog

---

## 2026-05-01 — Performance & UI Smoothness Pass

### Problem
UI stuttering and choppiness during fast scrolling and typing in large TypeScript files. blink.cmp `<CR>` sometimes inserting a newline instead of accepting. Copilot suggestions not appearing consistently.

---

### lua/plugins/scrollbar.lua
- **Disabled** `nvim-scrollbar` entirely (`enabled = false`)
- Reason: diagnostic + search mark handlers redrawed scrollbar marks on every LSP diagnostic update, causing cascading redraws in large TS files

---

### lua/plugins/copilot.lua
- **Removed** `copilot-lsp` (`copilotlsp-nvim/copilot-lsp`) dependency block
  - Reason: plugin was still loading and registering a background LSP client despite NES being `enabled = false`, causing interference with copilot.lua suggestion module and LSP slot competition
- **Changed** `hide_during_completion = false` → `true`
  - Reason: Copilot ghost text and blink.cmp menu competing for the same display area caused suggestions to not render reliably
- **Removed** dead NES Tab mapping inside `config` function
  - Reason: was already overridden by `keymaps.lua`'s Tab mapping and required the now-removed `copilot-lsp`

---

### lua/plugins/performance.lua — blink.cmp
- **Removed** entire `init` function containing comment-detection autocmds:
  - `CursorHoldI` — ran treesitter query after 200ms idle
  - `InsertEnter` — ran treesitter query on insert entry
  - `CursorMovedI` — reset `blink_in_comment` flag on every keystroke (per-keypress Lua overhead)
  - Reason: `CursorMovedI` fires on every character typed; combined with a stale `blink_in_comment` flag, was causing `<CR>` to fall through to newline instead of accepting completion
- **Simplified** `enabled` function — removed `blink_in_comment` check, now only guards Avante/prompt buffers
- **Added** `buffer` provider config: `min_keyword_length = 3`, `max_items = 10`
  - Reason: buffer source was scanning entire file on every completion trigger with no keyword threshold

---

### lua/plugins/performance.lua — lualine
- **Removed** custom LSP loading indicator (entire block):
  - `vim.g.lsp_loading` global
  - `LspAttach` autocmd that called `redrawstatus()` on every attach
  - `LspProgress` autocmd that called `redrawstatus()` on every progress event (even with 300ms throttle, was still causing excessive statusline redraws during heavy TS analysis)
  - `lualine_c` component reading `vim.g.lsp_loading`
- Replaced by fidget.nvim (see below)

---

### lua/plugins/fidget.lua — NEW FILE
- **Added** `j-hui/fidget.nvim` for LSP progress display
- Config:
  - `progress.poll_rate = 0` — event-driven, no polling
  - `progress.suppress_on_insert = true` — no spinner while typing
  - `progress.ignore = { "copilot", "copilot-lsp" }` — filters Copilot background chatter
  - `notification.override_vim_notify = false` — only handles LSP progress, leaves `vim.notify` untouched

---

### lua/plugins/folding.lua
- **Disabled** `statuscol.nvim` (`enabled = false`)
  - Reason: biggest source of scroll stuttering — replaced Neovim's native C-rendered sign/number/fold column with Lua callbacks running on every visible line during every redraw (~150 Lua calls per keypress during fast scroll). Falls back to Neovim's built-in column rendering.
  - nvim-ufo kept enabled: fold computation is one-time on `BufReadPost`; `zR`, `zM`, `zK`, `zm`, `zn` keymaps all still work

---

### lua/config/keymaps.lua
- Restored `zz` on `<C-d>`, `<C-u>`, `<C-f>`, `<C-b>` scroll maps
  - Note: was temporarily removed during diagnosis; restored after statuscol.nvim was disabled (the double-redraw cost is negligible without statuscol's per-line Lua overhead)

---

### lua/config/options.lua
- `scrolloff` 15 → 12 (user adjusted)
- `sidescrolloff` 15 → 6
  - Reason: reduces forced viewport shifts during fast j/k scrolling

---

### lua/plugins/lsp.lua
- **Added** global semantic token disable via `LspAttach`:
  ```lua
  client.server_capabilities.semanticTokensProvider = nil
  ```
  - Reason: stops all LSPs from computing and sending semantic token payloads on every file change. Highlighting falls back to treesitter. All other LSP features (diagnostics, completions, hover, go-to-definition, rename, code actions) unaffected.
