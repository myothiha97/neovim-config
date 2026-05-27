# LSP Popup Style Consolidation

## Goal
Single source of truth for LSP doc-popup styling (`border`, `max_width`, `max_height`) so hover, signature help, mouse hover, and the right-click PopUp menu all render with identical dimensions.

## Problem
Four entry points each carry their own copy of `{ border, max_width, max_height }`, with diverging values. A popup looks different depending on how it was opened.

| Entry point | File:line | border | max_width | max_height |
|---|---|---|---|---|
| `K` (LSP buffer-local) | `lua/plugins/lsp.lua:31` | rounded | 70 | 40 |
| `K` (global fallback, dead code under LSP) | `lua/config/keymaps.lua:30-32` | rounded | 80 | 30 |
| `<M-i>` signature | `lua/config/keymaps.lua:169` (uses `hover_opts`) | rounded | 80 | 30 |
| Mouse hover | `lua/config/mouse-hover.lua:275-277` | rounded | 80 | 20 |
| Right-click PopUp menu | `lua/config/options.lua:36, 41, 43` | rounded | 80 | 30 |

## Out of scope (intentionally separate)
- **Diagnostic floats** — `lua/config/options.lua:75-83`, `lua/config/keymaps.lua:200-209`, `lua/config/keymaps.lua:213-215`. Different content shape (short messages, `source`/`header`/`prefix` opts). Keep their own constant if consolidated later.
- **Universal LSP-float wrapper** — `lua/config/keymaps.lua:8-30`. Adds `foldcolumn = "1"` and `+2 width` to every float through `vim.lsp.util.open_floating_preview`. Already universal — no change needed. Composes cleanly with per-caller `max_width`/`max_height`.
- **Bespoke command floats** — `lua/config/keymaps.lua:~337` (Git Who), `~392` (Git Blame Line), `~533` (Unsaved Files). Content-driven sizing; share only `border = "rounded"` for visual consistency.
- **Plugin popup systems** — `blink-cmp.lua` (own renderer), `oil.lua`, `snacks.lua` (picker), `fidget.lua` (progress). Not routed through LSP util.

## Plan
1. Create `lua/config/lsp-popup.lua` returning a single table:
   ```lua
   return { border = "rounded", max_width = 80, max_height = 30 }
   ```
2. Replace the four duplicates above with `require("config.lsp-popup")`.
3. Special-case `options.lua:36` — it embeds a Lua table as a *string literal* inside a `:anoremenu` Vim command. Either:
   - Serialize the table back to a string at load time (`string.format`); or
   - Pre-build the string once after requiring the shared table.
4. Delete the dead global `K` mapping at `keymaps.lua:30-32` (LazyVim's buffer-local LSP K already wins). Or repoint it at the shared table for symmetry — pick one.

## Risks / things to verify
- `mouse-hover.lua` currently sets `max_height = 20` deliberately (smaller because mouse popups feel intrusive when tall). Decide: standardize on 30 or keep mouse hover shorter via a per-caller override.
- The `K` LSP buffer-local entry uses `max_width = 70` / `max_height = 40` — confirm intent before flattening. The taller value was set when debugging gopls hover width; may no longer be needed now that the bug is fixed.
- The right-click PopUp menu opts live in a string-cmd context; after the change, reproduce `mouseright` on a symbol → "Show Hover Docs" / "Show Signature Help" and confirm sizing matches `K`.

## Future extension
If diagnostic floats are also consolidated, do it as a *second* shared table (`lsp-diag-popup.lua`) — don't bundle the two together. They share `border` but nothing else.
