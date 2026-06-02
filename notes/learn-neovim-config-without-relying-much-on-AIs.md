# Learn Neovim Config Without Relying Too Much On AIs

## Goal

Become confident enough to understand, debug, and make small Neovim config
changes manually, using AI as a tutor/reviewer instead of the main driver.

This is not about memorizing all of Neovim. The goal is to learn the small set
of concepts that explain most of this LazyVim config:

- where config code lives
- when code runs
- how lazy.nvim plugin specs are shaped
- how keymaps, options, autocmds, commands, LSP, completion, and UI floats work
- how to make changes without hurting runtime performance

## Existing Docs To Reuse First

Read these before opening random blog posts or asking AI for a full answer:

| File | Use it for |
|------|------------|
| [`README.md`](../README.md) | Overview of this config's stack, keymaps, language support, and performance choices. |
| [`rules.md`](../rules.md) | Config freeze policy and the short performance checklist. |
| [`notes/safe-config-editing-guide.md`](../notes/safe-config-editing-guide.md) | Main guide for safe edits, hot-path rules, profiling, and pre-commit checks. |
| [`notes/reading-codebases-with-neovim.md`](../notes/reading-codebases-with-neovim.md) | Practical Neovim navigation habits: `gd`, `gr`, folds, marks, grep, jumplist. |
| [`docs/AGENTS.md`](../docs/AGENTS.md) | Repo structure, style rules, commands, and testing expectations. |
| [`notes/journal.md`](../notes/journal.md) | Historical context for decisions and previous debugging sessions. |

## Mental Model

Neovim config is just Lua that runs at different times. Most problems become
simple once you know **where the code lives**, **when it runs**, and **whether
it runs on the hot path**.

The fastest way to learn is to trace existing working examples, make tiny
changes, verify them, and write down the pattern. Avoid broad rewrites.

## TLDR Learning Path

1. Read `README.md`, then `rules.md`.
2. Learn the repo map: `init.lua` -> `lua/config/lazy.lua` -> `lua/config/*` +
   `lua/plugins/*`.
3. Pick one feature at a time: keymaps, options, autocmds, LSP, completion,
   folding, snippets, AI.
4. For each feature, read the local file first, then `:help`, then plugin docs.
5. Make one tiny manual edit, reload, test, and revert/keep.
6. Use AI only after you have a concrete question or want a review.

## Time Budget

Use this to avoid turning config learning into a time sink.

| Session | Time | Output |
|---------|------|--------|
| Quick lookup | 10-15 min | Answer one question, no config edit unless obvious. |
| Practice session | 30-45 min | Learn one concept and write 3-5 notes. |
| Config edit | 30-60 min | One scoped change, tested in real files. |
| Monthly batch | 1-3 hrs | Planned config changes only, with freeze unlock if needed. |

Rule: if a topic needs more than one hour, write a note and stop. Come back in
the next planned learning/config batch.

## Repo Map

| Path | What to learn there |
|------|---------------------|
| `init.lua` | Boot entry point. Keep it tiny. |
| `lua/config/lazy.lua` | How LazyVim and local plugin specs are loaded. |
| `lua/config/options.lua` | Global Neovim options and early globals. |
| `lua/config/keymaps.lua` | Global keymaps and custom interactive behavior. |
| `lua/config/autocmds.lua` | Event-driven behavior. Check hot-path safety. |
| `lua/config/ai-prompts.lua` | Small local Lua module pattern. |
| `lua/config/quickfix-persistence.lua` | Good example of bounded startup/exit I/O. |
| `lua/plugins/*.lua` | lazy.nvim specs and LazyVim plugin overrides. |
| `lua/plugins/lsp.lua` | LSP setup, server-specific settings, attach keymaps. |
| `lua/plugins/blink-cmp.lua` | Completion source setup and keymap behavior. |
| `lua/plugins/folding.lua` | Async folds and large-file guards. |
| `snippets/*.json` | VS Code-style snippet files used by blink.cmp. |

## Core Concepts To Learn

### 1. Runtime Path And Startup

Learn:

- `:set runtimepath?`
- `:scriptnames`
- `:h initialization`
- why `init.lua` loads first
- why `lua/config/lazy.lua` bootstraps lazy.nvim

Practice:

- Open `init.lua`.
- Use `gd` on `require("config.lazy")`.
- Use `<C-o>` to jump back.

### 2. Lua Module Basics

Learn only enough Lua to read and edit config:

- tables: `{}`, arrays, maps, nested options
- functions and anonymous callbacks
- `local` scope
- `return { ... }` plugin spec files
- `require("module.name")`
- `pcall(require, "...")` for optional plugins
- closures for shared state, like timers or helper functions

Useful help:

```vim
:h lua-guide
:h lua
:h lua-require
```

Practice:

- Read `lua/config/ai-prompts.lua` as a local module example.
- Read one small plugin file in `lua/plugins/`.
- Explain what table gets returned and when it runs.

### 3. Neovim API Essentials

Focus on these APIs first:

| API | Why it matters |
|-----|----------------|
| `vim.opt`, `vim.o`, `vim.bo`, `vim.wo` | Options: global, buffer-local, window-local. |
| `vim.g`, `vim.b`, `vim.w` | Global/buffer/window variables. |
| `vim.keymap.set` | Keymaps and callbacks. |
| `vim.api.nvim_create_autocmd` | Event-driven config. |
| `vim.api.nvim_create_augroup` | Prevent duplicate autocmds. |
| `vim.api.nvim_create_user_command` | Custom commands. |
| `vim.notify` | User-visible messages. Avoid in hot callbacks. |
| `vim.schedule`, `vim.defer_fn` | Delay work off the current event. |
| `vim.system` | Async shell commands. Prefer over blocking `vim.fn.system`. |
| `vim.lsp.*` | LSP navigation, hover, diagnostics, client state. |

Useful help:

```vim
:h vim.opt
:h lua-api
:h api
:h autocmd
:h user-commands
:h vim.schedule()
:h vim.system()
```

### 4. Options

Mental model: options change editor behavior. Some are global, some are local to
a buffer/window, and some are performance-sensitive.

Study:

- `lua/config/options.lua`
- `notes/safe-config-editing-guide.md`

Practice:

```vim
:verbose set scrolloff?
:verbose set updatetime?
:verbose set foldmethod?
```

Best practices:

- Prefer native options over custom Lua when possible.
- Use `:verbose set <name>?` to see who set an option.
- Do not change performance-sensitive options casually:
  `updatetime`, `foldmethod`, `lazyredraw`, `synmaxcol`,
  `diagnostics.update_in_insert`, semantic tokens, inlay hints.

### 5. Keymaps

Mental model: keymaps turn keys into editor actions. In this config, many maps
are intentionally shaped around Ghostty/tmux and LazyVim defaults.

Study:

- `lua/config/keymaps.lua`
- `README.md` key binding tables
- `docs/AGENTS.md` terminal/keybinding context

Useful help:

```vim
:h vim.keymap.set()
:h map-arguments
:h map-expression
:h :verbose-map
```

Practice:

```vim
:verbose nmap K
:verbose nmap gd
:verbose imap <Tab>
:verbose nmap <C-e>
```

Best practices:

- Always add a `desc`.
- Check collisions with `:verbose map <lhs>` before adding.
- Prefer LazyVim conventions over custom personal shortcuts.
- Be careful with `expr = true`; avoid window/text mutations directly inside
  expression mappings. Use `vim.schedule` when needed.
- Smoke-test terminal-sensitive keys: `<Tab>`, `<C-i>`, `<M-/>`, `<M-f>`,
  `<M-i>`.

### 6. Autocmds

Mental model: autocmds run because an event happened. The same code can be safe
on `VimEnter` and terrible on `CursorMoved`.

Study:

- `notes/safe-config-editing-guide.md`
- `lua/config/autocmds.lua`
- `lua/config/mouse-hover.lua`
- `lua/config/quickfix-persistence.lua`

Useful help:

```vim
:h autocmd-events
:h nvim_create_autocmd()
:h autocmd-groups
```

Best practices:

- Always use a named augroup with `clear = true`.
- Avoid `CursorMoved`, `TextChanged`, `InsertCharPre`, and mouse movement work.
- If unavoidable, throttle, dedup, and keep callbacks tiny.
- Scope by `pattern`, `buffer`, or `filetype`.
- Wrap optional plugin access in `pcall`.
- Test re-sourcing: source the file twice and confirm behavior does not double.

### 7. lazy.nvim And LazyVim Plugin Specs

Mental model: LazyVim gives the base config; local `lua/plugins/*.lua` files
add, disable, or override plugin specs.

Learn these lazy.nvim fields:

| Field | Purpose |
|-------|---------|
| plugin name | `"author/plugin.nvim"` |
| `enabled` | Disable without deleting the spec. |
| `event`, `ft`, `cmd`, `keys` | Lazy-load trigger. |
| `opts` | Options merged into plugin setup. |
| `config` | Custom setup function. |
| `init` | Runs before plugin loads. |
| `dependencies` | Extra plugins. Use sparingly. |

Useful commands:

```vim
:Lazy
:Lazy profile
:Lazy log
:LazyExtras
```

Best practices:

- Prefer LazyVim extras before custom plugin wiring.
- Prefer `opts` over custom `config` when possible.
- Lazy-load new plugins by `keys`, `cmd`, `ft`, or `event`.
- Do not re-enable disabled plugins without checking `rules.md` and the known
  disabled plugin list.
- Keep plugin files feature-focused: one file per plugin or feature area.
- Respect the freeze: plugin updates happen only in planned batches.

### 8. LSP

Mental model: LSP is a separate language server process. Neovim sends file
changes and receives definitions, diagnostics, hover docs, code actions, etc.

Study:

- `lua/plugins/lsp.lua`
- `README.md` language support section
- `todos/multi-language-support.md`

Useful help:

```vim
:h lsp
:h vim.lsp.buf
:h vim.diagnostic
:LspInfo
:checkhealth vim.lsp
```

Best practices:

- Keep shared behavior in `vim.lsp.config("*", ...)` when possible.
- Keep server-specific settings inside that server's table.
- Disable expensive features globally unless needed:
  semantic tokens, inlay hints, document color, insert-mode diagnostics.
- Guard root detection so loose files do not make `$HOME` a workspace.
- Prefer LSP for exact navigation: `gd`, `gr`, `gi`, `gy`, `K`.
- Use AI only after checking LSP facts.

### 9. Completion

Mental model: completion is a menu built from sources. Keep the source list
stable and cheap so typing stays instant.

Study:

- `lua/plugins/blink-cmp.lua`
- snippets in `snippets/`

Useful help/docs:

```vim
:h ins-completion
:h complete-functions
```

Best practices:

- Preserve `preset = "none"`.
- Keep source list stable: LSP, path, snippets, buffer.
- Do not add Tree-sitter checks inside the completion `enabled` path.
- Avoid auto-suppression logic in comments; use the existing manual toggle.
- Keep ghost text off for blink; Copilot ghost text has its own flow.

### 10. UI Floats, Popups, And Windows

Mental model: hover docs, diagnostics, pickers, and terminals are windows or
floating windows. Most custom behavior is about finding the right window and
changing focus/config carefully.

Study:

- `lua/config/keymaps.lua` popup handling
- `lua/config/mouse-hover.lua`
- `lua/plugins/noice.lua` if present or related UI plugin files

Useful help:

```vim
:h api-floatwin
:h nvim_open_win()
:h nvim_win_get_config()
```

Best practices:

- Do not assume every float is an LSP float. Skip Snacks picker/explorer floats.
- Avoid global monkey-patches unless there is no public API.
- If monkey-patching, document the exact reason and keep it version-frozen.
- Be careful when focus changes can trigger `BufLeave` or close popups.

## How To Learn Without Spending Too Much Time

### The 3-pass method

Use this for any file or feature:

1. **Skim:** read headings, comments, returned tables, and key functions.
2. **Trace:** follow one real path with `gd`, `gr`, `:verbose map`, or
   `:verbose set`.
3. **Change:** make one tiny safe edit, test it, then write a note.

Do not try to understand every line before touching anything. Learn by tracing
real behavior.

### The "one concept per session" rule

Good sessions:

- "Today I only learn `vim.keymap.set`."
- "Today I only learn autocmd augroups."
- "Today I only learn how `opts` merges into LazyVim plugin specs."
- "Today I only learn `vim.lsp.buf.definition` and `on_list`."

Bad sessions:

- "Today I learn all of Neovim config."
- "Today I rewrite the plugin structure."
- "Today I install five plugins and see what happens."

### Prefer local examples

Before searching online, find one existing example in this repo:

```sh
rg -n "vim.keymap.set" lua
rg -n "nvim_create_autocmd" lua
rg -n "pcall\\(require" lua
rg -n "vim.lsp" lua
rg -n "event =|keys =|cmd =|ft =" lua/plugins
```

Then read the smallest matching file first.

### Use built-in help effectively

Do not read help pages top-to-bottom. Use them like reference docs:

```vim
:h vim.keymap.set()
:h nvim_create_autocmd()
:h diagnostic-api
:h lsp
:h lua-guide
```

Inside help:

- `/pattern` to search.
- `<C-]>` to jump to help tags.
- `<C-o>` to jump back.
- `:h help-summary` when lost.

### Use plugin docs only after reading the local spec

Order:

1. Local config file.
2. LazyVim docs/extra, if this is a LazyVim feature.
3. Plugin README.
4. `:h plugin-name` if the plugin has help.
5. AI only for summarizing or comparing options.

This prevents copying plugin defaults that LazyVim already handles.

## AI Usage Rules

Use AI for:

- explaining a small code block after you read it once
- turning plugin docs into a short summary
- asking "what are the risks of this change?"
- generating a checklist before a config batch
- reviewing your diff before commit
- comparing two possible approaches

Do not use AI for:

- writing a whole config change before you understand where it belongs
- adding new plugins impulsively
- deciding performance safety without checking events and runtime frequency
- verifying exact keymap/option state; use `:verbose map` and `:verbose set`
- replacing `:help`, local source, or plugin docs

Good prompt pattern:

```text
I am editing a LazyVim-based Neovim config. Explain this specific block in
lua/plugins/lsp.lua. Focus on when it runs, what APIs it uses, and whether it
adds hot-path cost. Do not suggest new plugins.
```

Better workflow:

1. Read the block yourself.
2. Write your own guess in 2-3 sentences.
3. Ask AI to correct your model.
4. Verify with `:help`, `:verbose`, or source.

## Safe Practice Projects

Use these to build confidence without high risk.

### Practice 1: Add A Temporary Keymap

Goal: learn `vim.keymap.set`.

Steps:

1. Add one harmless normal-mode keymap in a scratch branch.
2. Include `desc`.
3. Check it with `:verbose nmap <lhs>`.
4. Remove it.

Do not commit unless it is genuinely useful.

### Practice 2: Inspect An Option

Goal: understand option ownership.

Steps:

1. Pick an option from `lua/config/options.lua`.
2. Run `:verbose set <option>?`.
3. Read `:h '<option>'`.
4. Write one note explaining why this config sets it.

Good options:

- `scrolloff`
- `sidescrolloff`
- `updatetime`
- `timeoutlen`
- `synmaxcol`
- `foldmethod`
- `foldlevel`

### Practice 3: Add A User Command

Goal: learn `vim.api.nvim_create_user_command`.

Example idea:

- command that prints the current buffer filetype
- command that copies current relative path

Rules:

- no shell command
- no plugin dependency
- no autocmd
- remove after practice unless useful

### Practice 4: Read One Plugin Spec

Goal: understand lazy.nvim specs.

Pick one small file from `lua/plugins/`.

Answer:

- What plugin is this?
- When does it load?
- Is it disabled?
- What options does it override?
- Does it add runtime cost while typing?

### Practice 5: Trace One LSP Key

Goal: understand LSP navigation.

Steps:

1. Run `:verbose nmap gd`.
2. Find the mapping source.
3. Read the callback in `lua/plugins/lsp.lua`.
4. Explain why it filters `node_modules` and current-file imports.

## Best Practices For This Config

- Default stance: do not edit config unless there is a real workflow reason or
  a planned batch.
- Performance comes first: no hot-path work unless heavily justified.
- Prefer native Neovim options and APIs over custom Lua callbacks.
- Prefer LazyVim extras and conventions over custom plugin wiring.
- Prefer small additive changes over broad refactors.
- Prefer reading source and `:help` over copying snippets.
- Keep comments short, but document fragile internals and performance choices.
- Use `pcall` around optional plugin access.
- Use augroups for autocmds.
- Use `vim.schedule` or `vim.defer_fn` to move heavy work out of the current
  event.
- Use large-file guards before Treesitter, regex scans, LSP-heavy operations, or
  loops over many lines.
- Use async shell commands (`vim.system`) when shell work is necessary.
- Avoid `vim.fn.system`, `io.popen`, sync Treesitter parsing, LSP requests, or
  `vim.notify` in frequent callbacks.
- Do not re-enable disabled plugins without reading the disabled list in project
  memory and checking `rules.md`.
- After every change, test typing, scrolling, buffer switching, and one real
  TS/React file.

## Debugging Commands To Memorize

```vim
:messages
:checkhealth
:Lazy
:Lazy profile
:Lazy log
:LspInfo
:Mason
:verbose nmap <lhs>
:verbose imap <lhs>
:verbose set <option>?
:au <Event>
:scriptnames
```

Shell checks:

```sh
stylua --check init.lua lua
XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache nvim --headless '+qa'
nvim --headless --startuptime /tmp/st.log +q
```

## Weekly Learning Plan

### Week 1: Orientation

- Read `README.md`.
- Read `rules.md`.
- Open `init.lua`, `lua/config/lazy.lua`, `lua/config/options.lua`.
- Goal: explain the boot path in 5 sentences.

### Week 2: Keymaps And Options

- Read the first half of `lua/config/keymaps.lua`.
- Run `:verbose nmap` for 5 mappings you use daily.
- Run `:verbose set` for 5 options.
- Goal: know where your daily editing behavior comes from.

### Week 3: Autocmds And Performance

- Read `notes/safe-config-editing-guide.md`.
- Read `lua/config/autocmds.lua` and `lua/config/mouse-hover.lua`.
- Goal: explain hot path vs cold path and name the red-flag events.

### Week 4: lazy.nvim And Plugins

- Read 3 small files in `lua/plugins/`.
- Open `:Lazy profile`.
- Open `:LazyExtras`.
- Goal: explain `opts`, `init`, `config`, `keys`, `cmd`, `event`, and `ft`.

### Week 5: LSP And Completion

- Read `lua/plugins/lsp.lua`.
- Read `lua/plugins/blink-cmp.lua`.
- Run `:LspInfo` in a TS file.
- Goal: explain how `gd`, `K`, diagnostics, and completion sources work.

### Week 6: Small Manual Change

- Pick one tiny improvement from a todo.
- Make the smallest possible edit.
- Run formatting/smoke checks.
- Write what you learned in `notes/journal.md` or the relevant todo.

## Checklist Before Any Real Config Edit

- [ ] Is this change allowed under `rules.md`, or should it go to a todo?
- [ ] Do I know which file owns this behavior?
- [ ] Do I know when this code runs?
- [ ] Does it touch a hot-path event or callback?
- [ ] Can I reuse an existing pattern from this repo?
- [ ] Have I checked `:help` or plugin docs for the exact API?
- [ ] Have I checked keymap/option/autocmd ownership with `:verbose` or `:au`?
- [ ] Is the change small enough to test manually?
- [ ] Did I run `stylua --check init.lua lua` for Lua changes?
- [ ] Did I smoke-test a real file, not just an empty buffer?

## Notes To Keep

Whenever you learn something, write a short note in this format:

```md
### Topic: vim.keymap.set

Mental model:
Keymaps bind keys to strings or Lua callbacks. The important parts are mode,
lhs, rhs, opts, and whether the mapping is expression-based.

Useful commands:
- `:h vim.keymap.set()`
- `:verbose nmap K`

Config example:
- `lua/config/keymaps.lua`

Footgun:
- `expr = true` mappings cannot safely mutate windows/text directly; schedule
  side effects.
```

This builds a personal Neovim manual from your own config instead of a generic
internet tutorial.
