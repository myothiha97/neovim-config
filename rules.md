# Personal rules for this Neovim config

Rules I commit to follow when working on this config. The "why" matters as
much as the rule — if the reason no longer holds, the rule is up for review.

## Config freeze policy (2026-05-24)

Core setup is complete. From now on:

- **Default stance:** don't touch the config. Even if I read about an "amazing"
  plugin, feature, or refactor — write it in `todo.md` and move on.
- **Allowed reasons to edit mid-month:** an actual error, bug, or broken
  workflow that blocks real work. Not "this could be nicer."
- **Cadence for configuration / optimization / customization batches:**
  once every 1 month, possibly every 3–4 months. Batch all the "would be
  nice" items into one focused session.
- **Why:** nvim config tinkering is a known time sink and distraction from
  the actual coding work. The freeze enforces this — `:Lazy update/sync/restore`
  is blocked at the lua level. See `lua/config/lazy-freeze.lua`.
- **Escape hatch for the monthly batch:** `NVIM_LAZY_UNLOCK=1 nvim`, then
  `:Lazy sync`. Single session only — next plain `nvim` is locked again.
- **For new features I want to try:** add them to `todo.md` under a
  "next batch" section. Don't open a plugin spec file just to "take a quick
  look" — that's how the time sink starts.
- **No immediate action on new ideas:** even if I come across a great idea,
  pattern, or plugin, I am not allowed to add or configure it on the spot.
  Every change must go through a plan and a scheduled timeline (the monthly /
  3–4 month batch), so nvim tinkering never bleeds into time owed to the
  professional job.

## Branching policy (never edit config on `main`)

- **Rule:** never add, change, or modify config directly on `main`. Always
  `git checkout` a `dev` branch or a specific feature branch first, make the
  changes there, then merge back via a reviewed/tested step.
- **Applies to:** any new plugin spec, config tweak, refactor, or doc change
  that touches behavior — not just big features.
- **Why:** `main` is the known-good config that boots every day. Keeping it
  clean means a broken experiment never leaves me with an unusable editor, and
  I always have a working branch to fall back to. Branches make changes easy to
  isolate, review, and discard if they don't pan out.

## Safe-editing quick reference (performance)

> Full guide: [`notes/safe-config-editing-guide.md`](notes/safe-config-editing-guide.md).
> Priority #1 is performance — zero hot-path cost. When in doubt, do less.

**The one question before adding anything:** *How often does this run, and is
it synchronous?* Per keystroke / cursor move / redraw = near-zero budget.

**Hot-path autocmds — justify or avoid:** `CursorMoved(I)`, `TextChanged(I)`,
`InsertCharPre`, `<MouseMove>` (fire thousands/session); `BufEnter`/`WinEnter`
(keep O(1)); `CursorHold` (light idle work only — they all fire together).

**Never on a hot path:** `vim.fn.system()`/`io.popen()` (blocking), synchronous
treesitter parse or `query:iter_captures`, blocking LSP requests, looping all
buffers/windows, `vim.notify`.

**Settings to leave alone:** don't enable `lazyredraw` (UI freezes with LSP);
don't set global `foldmethod=expr` (sync per-line scan — UFO handles it async);
keep `update_in_insert=false`, semantic tokens off, `synmaxcol` low,
`updatetime` ≥ 300.

**Always:**

- Wrap autocmds in a named augroup with `clear = true`.
- Guard new buffer/file work with a size check before treesitter/regex.
- `pcall` optional `require`s and any plugin-internal access.
- Lazy-load new plugins (`event`/`ft`/`cmd`/`keys`) unless startup-critical.
- Debounce/`vim.schedule` heavy work off the triggering event.
- Check keymap/autocmd collisions (`:verbose map <lhs>`) — this config
  overrides `gd`, `gf`, `K`, `<Tab>`, `<Esc>`, `<C-e>/<C-y>`.

**Reuse proven patterns:** `mouse-hover.lua` (throttle + dedup + reused timer)
for high-frequency handlers; `autocmds.lua`/`folding.lua` for large-file
guards. Internal monkey-patching is only acceptable because plugins are
version-frozen (`lazy-freeze.lua`).

**Before commit:** startup still ~40ms (`nvim --headless --startuptime`);
tested by typing/scrolling/switching in a large real file; behavior survives
re-sourcing (no duplicate effects).
