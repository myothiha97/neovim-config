# Repository Guidelines

## Project Structure & Module Organization
This repository is a LazyVim-based Neovim configuration. `init.lua` boots the setup through `lua/config/lazy.lua`. Keep editor-wide behavior in `lua/config/` (`options.lua`, `keymaps.lua`, `autocmds.lua`). Put plugin specs and overrides in `lua/plugins/`, usually one file per feature or plugin, such as `lsp.lua`, `formatting.lua`, or `todo-comments.lua`. Store custom VS Code-style snippets in `snippets/*.json`; `snippets/package.json` registers them.

## Build, Test, and Development Commands
- `XDG_STATE_HOME=/tmp/nvim-state XDG_CACHE_HOME=/tmp/nvim-cache nvim --headless '+qa'` checks that the config boots without touching your normal Neovim state.
- `nvim` launches the config for manual smoke testing.
- `:Lazy sync` refreshes plugins after editing specs or `lazy-lock.json`.
- `stylua --check init.lua lua` verifies Lua formatting from `stylua.toml`.
- `stylua init.lua lua` rewrites Lua files to the repo style.
- `:checkhealth` is useful for troubleshooting plugin, LSP, or provider issues.

## Coding Style & Naming Conventions
Lua is formatted with Stylua using spaces, 2-space indentation, and a 120-column width. Follow existing LazyVim conventions: return plugin specs from `lua/plugins/*.lua`, keep comments brief and purposeful, and prefer descriptive file names tied to a feature or plugin. Match the repo’s performance bias: avoid heavy per-keystroke logic, expensive autocmds, and blocking shell work in startup paths.

## Terminal & Keybinding Context
Primary usage is macOS + Ghostty + tmux. Review `/Users/mtkh97/.config/ghostty/config` and `/Users/mtkh97/.tmux.conf` alongside Neovim keymap changes. Ghostty keeps `macos-option-as-alt = false`, sends Meta through explicit `super+...=esc:...` bindings, and maps `ctrl+i` to CSI-u so `<C-i>` stays distinct from `<Tab>`. tmux enables `extended-keys`, `escape-time 0`, and `focus-events on`, with `Ctrl+Space` as prefix. Smoke-test `<C-i>`, `<Tab>`, `<M-/>`, `<M-f>`, `<M-i>`, and pane resize shortcuts after input-related edits.

## Testing Guidelines
There is no automated test suite in this repo. Validate changes by starting Neovim, exercising the affected workflow, and checking for startup errors or regressions. For plugin, completion, formatting, or LSP changes, run a quick manual pass over the related feature and refresh plugins with `:Lazy sync` when needed.

## Commit & Pull Request Guidelines
Git history follows conventional commit prefixes such as `feat:`, `fix:`, `perf:`, `refactor:`, and `chore:`. Keep commit subjects short, imperative, and scoped to one change, for example `fix: resolve prettierd fallback`. Pull requests should summarize the behavior change, list the touched modules, include manual verification steps, and add screenshots or short clips when UI elements like floats, themes, or statusline behavior change.
