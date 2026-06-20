## Neovim Config Change Gate

When I ask you to modify my Neovim configuration, do not immediately proceed.

This gate enforces the discipline in [`rules.md`](rules.md). During an active
**config-freeze window** (see `rules.md`), the bar is even higher — only fixes
that unblock the current workflow are allowed; everything else defers.

First, evaluate whether the requested change is truly necessary.

Only proceed if the change is important, such as:

- It fixes something that is blocking my actual development workflow.
- It resolves a serious bug that prevents me from using Neovim properly.
- It improves an existing workflow that I already rely on.
- It is required for my current professional work or core learning priorities.

Reject or defer the request if it is only:

- Aesthetic or visual polish.
- A minor UI change.
- A minor non-blocking bug.
- A new plugin installation.
- A new feature or new functionality.
- A speculative improvement.
- A change made only because I am distracted or over-optimizing my setup.

If the request is not truly necessary, do not edit the config. Instead, respond with this message:

> This Neovim change does not seem important enough to work on right now. It is not blocking your workflow or your current priorities.
>
> Your current priorities are Go & backend, Node/TS fullstack + the React portals (your daily work), DevOps & cloud infrastructure, Python, and system design.
>
> I recommend adding this to the `todos/` backlog instead of working on it now.

If the change may be useful later, suggest adding it as a file under `todos/` (the
backlog convention this repo already uses).

Before making any Neovim config change, briefly explain:

1. Whether the change is necessary or optional.
2. Whether it blocks my workflow.
3. Whether it supports my current priorities.
4. Whether you will proceed, reject, or defer it.

## Override

The gate is a speed bump, not a wall. If I acknowledge the reminder and still
**explicitly confirm** I want the change, proceed — but first restate in one line
that it's a non-essential change being made by choice, and offer to file it to
`todos/` instead. One conscious confirmation is enough; do not re-litigate.

Default behavior: reject or defer unless the change is clearly necessary.
