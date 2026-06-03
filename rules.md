# Personal rules for this Neovim config

> **The stakes.** Configuring Neovim is a proven time sink. Every "quick tweak"
> pulls focus from real work and, left unchecked, degrades my productivity and
> harms my professional career. The config is a *tool* for the job, not the job
> itself. When the urge to tinker shows up, the default answer is **no** — write
> it down, schedule it, get back to work. A config that boots and works is
> "done."

This file is the short list of rules I actually follow. It stays one screen on
purpose — I won't read a wall of text. The detailed reasoning and mechanics live
in the linked docs under [`References`](#references).

## The rules

1. **Don't touch the config on impulse.** The default answer to any new idea is
   **no** — capture it as a new file under `todos/` and move on. Never open a
   spec file "just to take a quick look."
   - **"It's trivial / quick" is not an exception — it's the trap.** Cosmetic
     and small preference tweaks (theme or color change, scroll speed, a keymap
     nudge, toggling an option) feel harmless *because* they're fast, and that
     is exactly how the bad habit forms. They are still impulse changes: they go
     into `todos/` and wait for the scheduled batch like everything else.
   - This is **not** the 30-minute rule (rule #8). That rule is only for fixing
     an actual bug or breakage — never for cosmetic or preference changes, no
     matter how quick they are.
2. **Edit mid-month only for critical must-fixes** — an actual error, bug, or
   broken workflow blocking real work. Not "nicer," "annoying," or "cleaner."
3. **New ideas need a plan and a scheduled date.** Batch them (monthly, or every
   3–4 months). Never configure something the moment it occurs to me.
4. **Never edit config on `main`.** Check out a `dev` or feature branch first,
   make the change there, merge back after it's reviewed and tested.
5. **Block ≥ 1–2 hr of dedicated, uninterrupted time** for any change. Fully
   verify it's safe, stable, and breaks nothing else. No half-done states.
6. **Never commit partial or half-done work.** Only complete, fully tested,
   proven-safe changes get committed — a WIP commit here is a future broken
   editor.
7. **Performance is priority #1** — zero hot-path cost, above features and
   polish. The one question before adding anything: *how often does this run,
   and is it synchronous?*
8. **30-minute rule for fixes:** a genuine quick fix (≤ 30 min) I do myself;
   anything needing real analysis or extended time gets delegated — even if the
   visible symptom looks small.

## References

The detailed, reasoning-heavy versions of the above:

- **Config freeze policy** — default stance, allowed reasons, cadence, the
  Lua-level `:Lazy` lock and its single-session escape hatch →
  [`notes/config-freeze-policy.md`](notes/config-freeze-policy.md)
- **Safe config editing (performance)** — the hot-path mental model, red-flag
  events/functions/settings, plugin-loading rules, pre-commit checklist →
  [`notes/safe-config-editing-guide.md`](notes/safe-config-editing-guide.md)
- **Maintenance & delegation** — the 30-minute rule in full, what stays mine vs.
  what to delegate →
  [`notes/config-maintenance-and-delegation.md`](notes/config-maintenance-and-delegation.md)
