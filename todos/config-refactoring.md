
# Config Refactoring

## Goal
Refactor and simplify configuration files to make them more consistent, maintainable, and easier to extend for additional languages.

## Unified Config Areas
- LSP
- Folding
- Search and replace
- Diagnostics
- Debugging
- Code analysis

## Language Priorities and Current State

| Language | Status |
|----------|--------|
| TS/JS    | Fully configured |
| Go       | Not configured yet |
| Python   | ~30% configured; some LSP features may already work |
| Rust     | Not configured yet |
| C        | Not configured yet |

## Planned Additions

### AI Action Keymaps / Commands
- Generate commit messages
- Analyze the codebase
- Review new changes

### Code Analysis Keymaps / Commands
- Check code coverage or code quality → display results in a popup or dedicated pane
- Analyze all variables, functions, classes, objects, and symbols used in a file (with usage counts) → display in a popup or dedicated pane

### Make the Neovim config as lean as possible

The config should stay small, predictable, and performance-safe. Every extra
Lua block, plugin override, helper function, or custom keymap increases the
maintenance cost, especially when it touches LazyVim defaults or plugin
internals. The goal is not to make the config clever; the goal is to make it
easy to understand, easy to change, and hard to accidentally slow down.

Refactoring priorities:

- Remove dead, duplicated, experimental, or rarely used config before adding
  new abstractions.
- Prefer LazyVim defaults, LazyVim extras, native Neovim options, and plugin
  `opts` over custom wrapper code.
- Keep feature ownership clear:
  - editor-wide behavior in `lua/config/`
  - plugin specs and overrides in `lua/plugins/`
  - reusable local helpers only when the same pattern is repeated enough to
    justify extraction
- Consolidate repeated patterns across LSP, formatting, diagnostics, folding,
  search/replace, and debugging, but avoid broad rewrites that make the config
  harder to trace.
- Keep runtime performance as the main constraint: no new hot-path work on
  `CursorMoved`, `TextChanged`, redraw/statusline paths, insert completion
  checks, or scroll events unless heavily justified and measured.
- Prefer small, boring modules with explicit names over "framework-style"
  abstractions. This is a personal config, not a plugin library.
- Document only the decisions that are non-obvious: performance tradeoffs,
  LazyVim overrides, plugin-internal patches, terminal/tmux keybinding
  constraints, and disabled-plugin rationale.
- Batch cleanup work during planned config sessions so refactoring does not
  become a constant distraction from actual coding work.

Concrete cleanup targets:

- Identify config blocks that are no longer used and either delete them or move
  them into a todo with rationale.
- Replace custom code with native options or LazyVim/plugin `opts` where that
  keeps the same behavior.
- Group related keymaps and commands by workflow so `keymaps.lua` is easier to
  scan.
- Wrap remaining autocmds in named augroups with `clear = true` when touching
  those files.
- Keep large-file guards, `pcall` protection, lazy-loading, and debounce/defer
  patterns consistent across modules.
- After each cleanup batch, verify startup, typing, scrolling, buffer switching,
  LSP hover/definition, completion, folds, and one real TS/React workflow.
