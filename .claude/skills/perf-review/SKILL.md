---
name: perf-review
description: Review the current uncommitted changes in this Neovim config for performance safety against the Performance Rules in docs/CLAUDE.md. Use this whenever the user is about to commit, asks to "check performance", "perf review", "review my changes", or whenever Lua plugin/config edits touch hot paths (autocmds, statusline/lualine, completion/blink.cmp, keymaps, LSP handlers). This config treats runtime snappiness as its #1 priority, so run this before committing any change that could add per-keystroke or per-render cost.
---

# Performance Review

This Neovim config is **performance-sensitive above all else** — runtime
snappiness is the non-negotiable #1 priority, ahead of features or polish. The
job of this skill is to audit the *current changes* and catch anything that adds
hot-path cost before it gets committed.

The source of truth for the rules is **`docs/CLAUDE.md` → "Performance Rules"
(lines 10-16)**. Re-read that section at the start of every review in case it
has changed — the checklist below is a working expansion of it, not a
replacement.

## Step 1 — Gather the changed files

Review **all uncommitted changes vs HEAD** (working tree + staged + untracked),
because the rule is "before committing, review ALL changed files."

```bash
git diff HEAD --stat
git diff HEAD                       # staged + unstaged tracked changes
git ls-files --others --exclude-standard   # untracked files (new lua/snippets)
```

Read the full diff for each changed `.lua` file. Focus on what the change *adds
to a hot path*, not cosmetic edits.

## Step 2 — Audit against the hot-path checklist

A "hot path" is any code that runs per keystroke, per cursor move, per render,
or on every buffer/window event. Cost there is multiplied thousands of times a
session. Flag anything in the diff matching these patterns:

- **Per-keystroke autocmds** — `TextChanged`, `TextChangedI`, `InsertCharPre`,
  `CursorMoved`, `CursorMovedI` callbacks that do real work (parsing, scanning
  buffers, RPC, formatting) without debounce/throttle. These are the most
  common offenders.
- **Expensive autocmds on frequent events** — `BufEnter`, `WinEnter`,
  `CursorHold` doing filesystem walks, `vim.fn.system`, git calls, or large
  table builds on every fire.
- **Blocking operations** — synchronous `vim.fn.system`, `io.*` reads,
  `:redraw`-forcing calls, or anything that stalls the UI thread. Prefer async
  (`vim.system`, `vim.uv`/`vim.loop`) or defer.
- **Statusline / lualine cost** — any per-render computation; lualine must stay
  throttled to **500ms** refresh (do not lower it). No git/LSP/fs calls computed
  inline on every redraw.
- **Completion (blink.cmp)** — new sources, scanners, or providers that run on
  every keystroke; respect existing debounces (vtsls 200ms). Don't add
  always-on sources to hot filetypes.
- **Re-enabling perf-disabled plugins** — these are off *on purpose*: noice,
  nvim-lint, bufferline, persistence, mini.ai, treesitter-context.
  Re-enabling any of them is a flag unless the user explicitly asked.
  (gitsigns is now enabled — `LazyFile`-deferred, signs/hunks only, blame off.)
- **External LSP where in-process would do** — prefer snippets / treesitter over
  spinning up another language server (rule: "in-process over external LSP").
- **Eager `require`/work at startup** — heavy module loads outside `lazy` /
  event guards that hurt startup time.

For each suspected issue, confirm it's actually on a hot path before flagging —
a one-time setup call or a command-triggered function is fine even if it's
"expensive."

## Step 3 — Report

Keep it short. The config owner wants a verdict, not an essay. Use this shape:

```
Performance review — N changed file(s)

✅ PASS  (or ⚠️ ISSUES FOUND)

<file>:<line> — <what runs on which hot path> → <why it's a cost> → <fix>
...

Verdict: safe to commit  /  fix the above first
```

If everything is clean, say so plainly in one or two lines and **do not lecture
the user about performance** — per the rule, only raise performance when there's
an actual issue. When there *are* issues, give the cheapest concrete fix
(debounce, defer, throttle, make async, gate behind a less-frequent event, or
drop the change).
