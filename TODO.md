# TODO

## Copilot manual trigger keymaps
Implement working keymaps for manual Copilot triggering:
- `<leader>at` — manual trigger from normal mode
- `<M-o>` — manual trigger from insert mode
- `<leader>ap` — open Copilot panel for multi-line suggestions

Previous attempts using `suggestion.next()` and `require("copilot.panel").open()` did not work.

## Copilot multi-line inline suggestions
Multi-line inline suggestions are limited in JS/TS files with copilot.lua.
Consider Avante.nvim for intentional multi-line AI edits (Cursor-like Cmd+K experience).
