# render-markdown.nvim for LSP Hover Popups & Avante

> Deferred 2026-05-28.

## Goal
Polished, Zed/WebStorm-style rendered markdown inside LSP hover docs popups and
Avante chat — no raw `` ``` `` fences, no toggle between rendered and raw when
the cursor sits on a markdown-syntax line.

## Current State
Plugin spec exists at `lua/plugins/render-markdown.lua` but is `enabled = false`.
The non-render-markdown polish (spell off, conceallevel=3, concealcursor=n on
LSP floats) lives in `lua/config/keymaps.lua` inside the `open_floating_preview`
override — that part stays on and is unaffected.

## What Worked
- Treesitter parsers added to `ensure_installed`: `markdown`, `markdown_inline`
- `file_types = { "markdown", "Avante" }` — auto-attach scope
- `overrides.buftype.nofile`: `render_modes = true`, `padding.highlight = NormalFloat`, `sign.enabled = false`, `code = { language = false, sign = false }` (removes the "lua/typescript" code-block header chip)
- Inline code chips, code-block backdrop, italics all rendered correctly

## What Did NOT Work
**The cursor-line raw markdown toggle persisted.** With cursor on a `` ```js ``
fence line, the fence renders as raw despite both layers trying to force `concealcursor = "n"`:

1. `lua/config/keymaps.lua` sets `vim.wo[winid].concealcursor = "n"` at popup open
2. render-markdown `win_options = { concealcursor = { default = "n", rendered = "n" } }` pins both states

Even with both, the conceal is revealed when the cursor sits on the fence line.
Something is resetting `concealcursor` post-render, OR render-markdown's conceal
extmarks for fence delimiters don't respect `concealcursor` the way native
syntax conceal does.

## Diagnostic Next Step When Resuming
1. Re-enable the plugin (remove `enabled = false` in `lua/plugins/render-markdown.lua`).
2. Open an LSP hover popup, move cursor onto the `` ``` `` fence line.
3. Run `:lua print(vim.wo.concealcursor, vim.wo.conceallevel)` — check actual values.
4. If `concealcursor` is empty: something is resetting it; add a buffer-local `CursorMoved` autocmd on the float that re-pins it.
5. If `concealcursor` is `"n"` but fence still shows raw: the issue is render-markdown's extmark conceal not honoring `concealcursor`. May need to file an issue or use a different approach (e.g. an autocmd that strips fence lines from the buffer entirely on open).

## Alternative Path to Consider
Skip render-markdown for hover popups specifically; keep it for Avante only
(`file_types = { "Avante" }`). For hover popups, write a small post-processor
that strips ` ```language ` and trailing ` ``` ` lines from the buffer in the
`open_floating_preview` override — cheap, no plugin needed, no toggle possible.

## Related Files
- `lua/plugins/render-markdown.lua` — plugin spec (disabled)
- `lua/config/keymaps.lua` — `open_floating_preview` override (spell/conceal floor, keeps working)
