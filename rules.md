# Personal rules for this Neovim config

> **Important reminder:** Neovim configuration can easily become a time sink.
> Every "quick tweak" can pull attention away from real work, and if it happens
> too often it reduces my productivity and hurts my professional growth.
>
> This config is only a **tool for work** — it is not the work itself.
>
> When I feel the urge to change something, the default answer is **no**:
> write the idea down, schedule it, and go back to real work.
>
> A config that starts correctly and works well is already **done enough**.

This file holds the rules I actually follow. It is intentionally short so I can
read it in one pass. The detailed explanations live in the linked documents
under [References](#references).

---

## Rules

1. **Do not change the config on impulse.**
   The default answer to any new idea is **no**. Write the idea as a new file
   under `todos/` and keep working. Never open a config or spec file "just to
   quickly check something."

   - **"It is quick" or "it is easy" is not an exception — it is the trap.**
     Small changes feel harmless *because* they are fast, and that is exactly how
     the bad habit starts. These still count as impulse changes:
     - theme or color changes
     - scroll speed changes
     - small keymap changes
     - option toggles
     - minor visual or preference tweaks

     Add them to `todos/` and handle them later in a scheduled config session.
   - This is **not** the 30-minute fix rule (rule #8). That rule is only for real
     bugs or broken workflows — never for cosmetic or preference changes.

2. **Only edit the config mid-month for critical fixes.**
   A critical fix is a real error, bug, or broken workflow that blocks actual
   work. Do not edit just because something feels nicer, annoying, cleaner, more
   beautiful, or slightly better.

3. **Every new idea needs a plan and a scheduled date.**
   Do not configure something the moment the idea appears. Collect ideas and
   handle them in batches — about once a month, or once every 3–4 months.

4. **Never edit the config directly on `main`.**
   Always switch to a `dev` or feature branch first. Merge back only after the
   change is reviewed, tested, and confirmed safe.

5. **Reserve at least 1–2 hours of focused, uninterrupted time for any change.**
   Do not make config changes in random small breaks. Every change must be
   verified to be safe, stable, complete, and not breaking other parts of the
   editor. Never leave the config in a half-finished state.

6. **Never commit partial or unfinished work.**
   Only commit changes that are complete, tested, and proven safe. A
   work-in-progress commit here can become a broken editor later.

7. **Performance is the top priority.**
   It matters more than new features, polish, or visuals. Before adding anything,
   ask: *how often does this run, and is it synchronous?* Avoid anything that
   adds cost to hot editor paths — keystrokes, cursor moves, and redraws.

8. **Use the 30-minute rule for real fixes only.**
   A real bug that can be fixed in ≤ 30 minutes, I fix myself. Anything needing
   deeper analysis or more time gets delegated — even if the visible issue looks
   small.

---

## References

The detailed, reasoning-heavy versions of the rules above:

- **Config freeze policy** — default stance, allowed reasons, the batch
  schedule, the Lua-level `:Lazy` lock, and its single-session escape hatch.
  [`notes/config-freeze-policy.md`](notes/config-freeze-policy.md)
- **Safe config editing guide** — the performance-first mindset, hot-path risks,
  risky events/functions/settings, plugin-loading rules, and the pre-commit
  checklist.
  [`notes/safe-config-editing-guide.md`](notes/safe-config-editing-guide.md)
- **Maintenance and delegation** — the full 30-minute rule, and what to handle
  myself versus what to delegate.
  [`notes/config-maintenance-and-delegation.md`](notes/config-maintenance-and-delegation.md)
