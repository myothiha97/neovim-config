
# Nvim: Rendered Markdown Preview for `.md` Files

## Goal
Be able to review the *rendered* output of real `.md` files directly inside Neovim —
the way you'd see it on GitHub or in a GUI editor's preview pane — instead of reading
raw markdown source.

## Current State
- `render-markdown.nvim` is already installed but **disabled** and intentionally scoped
  to LSP hover popups and Avante windows only — see `lua/plugins/render-markdown.lua`.
  Its header comment explicitly marks real `.md` files as out of scope.
- There is no in-editor preview for actual markdown files today.
- Deferred on purpose: a lot of time has already gone into the config, so this is parked
  as a future enhancement rather than done now.

## Approaches to Evaluate
Three architecturally different paths — decide based on fidelity vs. weight:

- **In-buffer conceal rendering** (stays in the terminal, no external process)
  - `render-markdown.nvim` — already present; would mean extending `file_types` to include
    real markdown buffers and adding the `FileType` autocmd / `buf_disable()` guard the
    current header comment hints at.
  - `markview.nvim` — alternative with richer in-buffer rendering.
- **External browser preview** (true HTML/CSS fidelity, but spawns a server)
  - `markdown-preview.nvim`, `peek.nvim`.
  - Highest fidelity (tables, mermaid, images) but heaviest; breaks the "stay in terminal" flow.
- **Terminal renderer in a float** (`glow` via a floating terminal)
  - Lightweight, read-only, decent fidelity; no live-reload.

## Requirements
- **Performance-safe (non-negotiable):** zero cost on the hot path. Any solution must be
  lazy-loaded on the `markdown` filetype only and must not add redraw overhead to normal editing.
- Must not regress the existing hover-popup / Avante markdown rendering, which depends on the
  current narrowly-scoped `render-markdown.nvim` config.
- Prefer a toggle (render ↔ raw source) rather than always-on, so editing raw markdown stays easy.

## Notes
- If choosing the in-buffer route, reuse the existing `render-markdown.nvim` spec rather than
  adding a second markdown plugin — extend `file_types` and add the `buftype ~= "nofile"`
  guard the current comment describes.
- Cross-reference: `todos/avante-ui-optimization.md` notes markdown preview was disabled in the
  Avante chats panel — confirm any change here doesn't re-enable that unintentionally.
