# TODO

## Tailwind LSP document color highlights
`tailwindcss-language-server` renders inline color swatches (light yellow/colored backgrounds) on arbitrary hex classes like `bg-[#F8F6F5]` via `textDocument/documentColor`.

Attempted fixes:
- `vim.lsp.document_color.disable(args.buf)` — errored: `disable` is nil in Neovim 0.12
- `vim.lsp.handlers["textDocument/documentColor"] = function() end` — no error but highlight persists

The highlight likely comes from a separate mechanism (possibly treesitter or tailwindcss server pushing semantic tokens instead of documentColor). Needs further investigation.

## Copilot manual trigger keymaps
Implement working keymaps for manual Copilot triggering:
- `<leader>at` — manual trigger from normal mode
- `<M-o>` — manual trigger from insert mode
- `<leader>ap` — open Copilot panel for multi-line suggestions

Previous attempts using `suggestion.next()` and `require("copilot.panel").open()` did not work.

## Copilot multi-line inline suggestions
Multi-line inline suggestions are limited in JS/TS files with copilot.lua.
Consider Avante.nvim for intentional multi-line AI edits (Cursor-like Cmd+K experience).
