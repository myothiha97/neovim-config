---
name: perf-review
description: Review all current uncommitted changes in this Neovim config for runtime and startup performance, implementation quality, bad patterns, and backward compatibility. Use when Codex or Claude Code is about to commit, when the user asks to check safety, performance, or changes, or when Lua edits affect existing behavior or hot paths.
---

# Neovim Performance Review

Audit all current changes before they are committed. Confirm that they preserve
runtime responsiveness, keep startup cost bounded, avoid fragile or wasteful
implementation patterns, and remain compatible with existing workflows unless
the user explicitly requested a behavior change.

## Read the current rules

Read the active repository instructions first:

- Codex: every applicable `AGENTS.md`.
- Claude Code: every applicable `CLAUDE.md`.
- In this repo, also re-read `docs/CLAUDE.md` → **Performance Rules**.

Treat those files as authoritative when this checklist differs from them.

## Gather every change

Review staged, unstaged, and untracked files:

```bash
git diff HEAD --stat
git diff HEAD
git ls-files --others --exclude-standard
```

Read the complete diff for every changed Lua file. Review what the change adds
to runtime paths, not only its stated intent.

## Audit hot paths

A hot path runs per keystroke, cursor move, scroll, redraw, render, or frequent
buffer/window event.

Flag these unless they are demonstrably bounded and cheap:

- `CursorMoved`, `CursorMovedI`, `TextChanged`, `TextChangedI`,
  `InsertCharPre`, `WinScrolled`, or `ModeChanged` callbacks doing real
  work.
- Frequent `BufEnter`, `WinEnter`, or `CursorHold` callbacks that scan
  buffers, walk files, build large tables, call git/LSP, or force redraws.
- Blocking `vim.fn.system`, synchronous file I/O, or other UI-thread work.
- Per-render statusline or UI computation. Keep lualine refresh at 500 ms and
  avoid inline git, LSP, or filesystem calls.
- New always-on blink.cmp sources, scanners, or providers.
- Re-enabling any plugin or feature marked disabled in the active repository
  instructions.
- Starting an external LSP when an in-process solution is sufficient.
- Heavy eager `require` or setup work. Runtime hot-path safety still takes
  precedence over a small bounded startup-only cost.

Do not flag one-time setup, explicit keypress callbacks, rare events such as
`VimEnter`, `VimLeavePre`, or `ColorScheme`, or panel-local work that only
exists while the panel is open—unless the work itself is heavy.

For every suspected issue, confirm which event triggers it, how often it runs,
and whether a guard, debounce, throttle, or scope makes the cost bounded.

## Audit implementation and compatibility

Check every change for:

- Accidental changes to existing keymaps, native Vim behavior, plugin loading,
  persistence, panels, completion, LSP behavior, or user-visible workflows.
- Plugin API assumptions that do not match the locked plugin version.
- Eager loading, duplicated state, stacked autocmds, missing cleanup, unsafe
  indexing, or unguarded optional module calls.
- Blocking or failure-prone work without a bounded fallback or `pcall` where a
  recoverable failure is expected.
- Unnecessary custom code where a stable Neovim, LazyVim, or plugin-native
  mechanism already provides the behavior.
- Comments, key descriptions, documentation, and tests that no longer match
  the resulting behavior.

Treat backward compatibility as the default. When a change intentionally
replaces behavior, verify the replacement and confirm unrelated workflows stay
intact.

## Verify

For changed Lua files, run the available syntax and boot checks:

```bash
luajit -bl <changed-file>
XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache nvim --headless '+qa'
git diff --check
```

Use feature-specific empirical checks for both the new behavior and important
existing behavior that could regress. Do not claim a change is safe or
backward-compatible only because the code parses.

## Report

Keep the result short:

```text
Performance review — N changed file(s)

✅ PASS

Runtime: safe
Startup: safe
Implementation: safe
Compatibility: preserved
```

Or, when problems exist:

```text
Performance review — N changed file(s)

⚠️ ISSUES FOUND

<file>:<line> — <trigger and frequency> → <cost> → <cheapest fix>

Verdict: fix the above first
```

If everything passes, say it is safe to commit without adding a performance
lecture. A pass means runtime, startup, implementation quality, and backward
compatibility were all reviewed—not only raw speed.
