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
