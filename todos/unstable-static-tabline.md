# Unstable Static Tabline

> **Priority: HIGH.** Parked on 2026-07-20. Do not re-enable outside a planned
> config session.

The local implementation is retained at `lua/config/_unstable_tabline.lua`, but
is intentionally inactive: `init.lua` does not require it and Snacks Explorer
has no tabline hooks.

## Why it is parked

- A blank/white strip appears at the top of the Neovim window.
- The visual design is still too basic for the intended VS Code-style tabs.
- Re-enable only after confirming a clean layout with Snacks Explorer,
  CodeCompanion, Grug-far, Trouble, Oil, and floating Snacks pickers.

## Resume checklist

- Find the source of the top whitespace without adding redraw-path work.
- Design and visually test the tabline states: active, inactive, modified,
  pinned, diagnostics, truncation, and Explorer offset.
- Re-run syntax, clean boot, keymap, panel-layout, and large-buffer performance
  checks before restoring the `init.lua` require and Explorer callbacks.
