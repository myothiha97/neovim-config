
# Keymap Native Conflicts

> **Priority: HIGH.** Deferred (needs thought, not a quick patch). Tackle in a planned
> config session.

## Goal
Resolve custom keymaps that shadow native Vim bindings in normal / insert / visual mode,
**preserving native behavior** instead of silently overwriting it.

## Guiding Principle
When a map conflicts with a native binding, choose the *safest* resolution, not the newest map:

- **Fallback** — for plugin maps only meaningful in a transient state (completion menu or
  suggestion open): add `"fallback"` so the key falls through to native when that state is
  absent. Reference fix already applied: `lua/plugins/blink-cmp.lua`
  `["<C-h>"] = { "show_documentation", "hide_documentation", "fallback" }`.
- **Relocate** — for unconditional function maps on native keys (no state to gate on): move
  the custom feature to a free key and reclaim the native binding.

## 🔴 High-impact (native command fully shadowed → relocate)

| Key | Native meaning (lost) | Current override | Safe resolution |
|-----|----------------------|------------------|-----------------|
| `gi` ✅ | Resume insert at last edit position | Line diagnostics float (`keymaps.lua:248`) | Done — moved to `<leader>cd`, native `gi` reclaimed |
| `ge` ✅ | Motion: back to end of prev word | Next ERROR (`keymaps.lua:266`) | Done — commented out; LazyVim `]e` covers next error |
| `gp` ✅ | Paste, cursor after pasted text | Prev ERROR (`keymaps.lua:275`) | Done — commented out; LazyVim `[e` covers prev error |
| `gf` ✅ | Go to file under cursor | Function start, treesitter (`keymaps.lua:530`) | Done — commented out; LazyVim `]f`/`[f` nav functions |
| `gh` ✅ | Start Select mode | Function end, treesitter (`keymaps.lua:544`) | Done — commented out; LazyVim `]F`/`[F` for function end |
| `<C-k>` (insert) ✅ | Digraph entry (`<C-k>e'`→é, `->`→→) | Copilot toggle (`copilot.lua:205`) | Done — moved to `<M-k>` (+`<D-k>` Neovide mirror); native digraph reclaimed |

## 🟡 Medium

- `<C-i>` / `<Tab>` (insert) — `blink-cmp.lua:44` `["<C-i>"] = { "show", "hide" }` has **no
  `"fallback"`**. Same byte as `<Tab>`; collides with the `<Tab>` map in `keymaps.lua:235`.
  Fix = add `"fallback"` (mirror the `<C-h>` fix), then test Tab-indent still works.
- `<S-h>` / `<S-l>` — buffer cycle (`bufferline.lua:105-106`) shadows native `H`/`L`
  (top/bottom of screen). Intentional; relocate buffers to `[b`/`]b` if `H`/`L` wanted back.
- `<C-j>` (insert) — Copilot trigger (`copilot.lua:153`) shadows native newline. Low harm;
  move to `<M-j>` if needed.

## 🟢 Low / keep as-is
- `K`, `gd` — LSP overrides, intentional and standard.
- `zm`, `zn` — ufo fold toggles, intentional (shadow native fold-level commands).
- visual `s` — vim-surround; `s` ≡ `c` in visual, so no real loss.
- normal `<Esc>` — clear highlights / close floats; only a tiny pending-count edge case.
- `<S-arrows>` — resize; shadows rarely-used native scroll/word-motion.

## ⚠️ Non-native but real self-collisions (fix in the same pass)
- ✅ `<leader>m` — Resolved. Quickfix "Add line to Quickfix" (`keymaps.lua:669`) is the
  owner. Harpoon is `enabled = false`, so no live clash; a CONFLICT comment at
  `harpoon.lua:76` flags it to relocate (→ `<leader>ha`) if harpoon is ever re-enabled.
- `<M-i>` in both `keymaps.lua:216` and `mouse-hover.lua` — verify no collision.

## Notes
- Line numbers captured 2026-06-07; re-verify before editing as the config evolves.
- Leader maps never conflict with native Vim, so only bare keys and `<C->/<M->/<S->` chords
  are in scope here.
