# Quickfix List Persistence

## Goal

Persist the manually curated quickfix list across Neovim restarts, especially entries added with `<leader>m`, so closing Neovim does not discard the working review list.

## Current State

- No quickfix persistence exists yet.
- Current `setqflist` / `getqflist` usage is limited to manual quickfix keymaps and a few feature-specific lists.
- Closing Neovim loses the quickfix list because it is currently only in memory.

## Proposed Approach

- Add an autocmd on `VimLeavePre` to save the current quickfix list to a small JSON file.
- Add an autocmd on `VimEnter` to restore it once at startup.
- Key the saved file by project cwd so quickfix lists do not bleed across repos.
- Cap restored entries, for example to the last 200, so startup cost stays bounded.
- Wrap all I/O in `pcall` so read/write failures never block startup or quit.

## Performance Constraints

- Must stay off interactive hot paths.
- No `CursorMoved`, `TextChanged`, scroll, or per-buffer hooks.
- One small write on exit and one small read on startup only.

## Relevant Files

- `lua/config/autocmds.lua`
- `lua/config/keymaps.lua`

