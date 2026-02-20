# My personal Neovim Configuration

A performance-optimized [LazyVim](https://github.com/LazyVim/LazyVim) setup for Full-Stack development and DevOps workflows.

## Features

- File navigation with oil.nvim (floating explorer) and Snacks.picker
- Autocompletion via blink.cmp with LSP, snippets, path, and buffer sources
- Copilot inline suggestions with word/line accept controls
- Git blame with floating window previews
- Treesitter-powered function navigation and text objects
- Search and replace with grug-far (project-wide and per-file)
- Diagnostics navigation and error fixing with custom shortcuts
- Todo comments tracking with quick navigation
- Code formatting with prettierd
- Language support: TypeScript, JavaScript, Python, Go, Ruby, Lua, Rust, C/C++

## Disabled Plugins

Plugins disabled from LazyVim defaults for performance:

| Plugin | Reason |
|--------|--------|
| `nvim-lint` | TypeScript LSP sufficient |
| `gitsigns.nvim` | Heavy in large repos |
| `bufferline.nvim` | Constant recalculation |
| `persistence.nvim` | Session micro-freezes |
| `mini.ai` | Not needed |
| `treesitter-context` | Heavy in large repos |
| `friendly-snippets` | Unsupported transform syntax |
| `flash.nvim` | Disabled |

`noice.nvim` is re-enabled but restricted to cmdline UI only (all other features disabled).

## Copilot

Inline suggestions with 75ms debounce and auto-trigger enabled.

| Key | Action |
|-----|--------|
| `<C-l>` / `<C-;>` / `<C-'>` | Accept full suggestion |
| `<M-w>` | Accept word |
| `<M-l>` | Accept line |
| `<M-]>` / `<M-[>` | Next / previous suggestion |
| `<leader>ad` | Toggle auto-trigger |

## Completion (blink.cmp)

| Key | Action |
|-----|--------|
| `<C-n>` / `<C-p>` | Navigate items |
| `<CR>` | Accept completion |
| `<C-i>` | Toggle completion menu |
| `<C-e>` | Close menu |
| `<C-h>` | Toggle documentation |
| `<Tab>` / `<S-Tab>` | Passthrough (indent/outdent) |

- **Sources**: Snippets (priority 1000) > LSP (100) > Path > Buffer
- **Ghost text**: Disabled
- Completions disabled in comments (cached detection) and Avante buffers
- Documentation auto-shows after 200ms
- Emmet bracket-only completions filtered out
- Async snippet processing enabled

## LSP

| Server | Config |
|--------|--------|
| `vtsls` | TypeScript, 200ms debounce |
| `emmet_ls` | HTML only (not TSX/JSX) |
| `eslint` | Disabled |

- Inlay hints disabled
- Diagnostics: `update_in_insert = false`, rounded borders, 60-char max width
- Custom `gd` filters out `node_modules` and skips import-line definitions

## Formatting

`prettierd` for JS, TS, JSX, TSX, JSON, HTML, CSS, SCSS, Markdown, YAML, GraphQL. Falls back to `~/.config/prettier/.prettierrc` when no project config exists.

## File Explorer (oil.nvim)

- `<leader>e` toggles floating explorer (80% width/height)
- Custom dark backdrop overlay
- `q` / `<Esc>` to close

## Theme

Tokyonight (`night` style) with custom overrides:
- Visual selection: `#264f78` (VS Code style)
- Cursor line number: `#02b890` (Ghostty green)
- Unused code (`DiagnosticUnnecessary`): `#737aa2` italic

## Key Bindings

### General

| Key | Mode | Action |
|-----|------|--------|
| `<leader>va` | n | Select all |
| `<leader>ya` | n | Yank all |
| `<leader>as` | n | Copy file path to clipboard |
| `<M-/>` | n/v | Toggle comment |
| `<C-d>/<C-u>` | n | Half-page scroll (recentered) |
| `<C-f>/<C-b>` | n | Full-page scroll (recentered) |
| `<Tab>` | n | LSP hover |
| `<M-i>` | i/n | Signature help (Option+i) |
| `<leader>l` | v | Insert language-aware log statement |

### Git

| Key | Action |
|-----|--------|
| `<leader>gw` | Git Who — compact blame info in floating window |
| `<leader>gb` | Git Blame Line — full commit diff in floating window |

### Diagnostics

| Key | Action |
|-----|--------|
| `gi` | Show line diagnostics |
| `ge` | Next error |
| `gp` | Previous error |

### Navigation

| Key | Action |
|-----|--------|
| `gf` | Go to function start (treesitter) |
| `gh` | Go to function end (treesitter) |
| `[f`/`]f` | Navigate functions (textobjects) |

### Treesitter Text Objects

`af`/`if` (function), `ac`/`ic` (class), `aa`/`ia` (parameter)

### Picker (Snacks)

| Key | Action |
|-----|--------|
| `<leader><leader>` | Smart finder (recent + buffers + workspace) |
| `<leader>ff` | Find files (root) |
| `<leader>fi` | Find files (current dir) |
| `<leader>fp` | Switch project |
| `<leader>sl` | Grep current file |

### Search & Replace (grug-far)

| Key | Action |
|-----|--------|
| `<leader>sr` | Search & replace (project, smart file filter) |
| `<leader>sf` | Search & replace in current file |

## Snippets

VSCode JSON format in `snippets/` using blink.cmp built-in provider (not LuaSnip).

- **es6-javascript.json** — Console, imports, exports, arrow functions (`af`, `afa`), named functions (`fa`, `faa`), anonymous functions (`nfa`, `nfaa`), destructuring, loops, async/await, error handling
- **typescriptreact.json** — React hooks (`useState`, `useEffect`, `useRef`, `useMemo`, `useCallback`), JSX helpers

## Performance Tuning

- **Comment detection**: Cached on `CursorMovedI` (not every keystroke)
- **vtsls debounce**: 200ms (default 100ms)
- **Copilot debounce**: 75ms
- **Snippets**: Async processing enabled
- **Lualine refresh**: 500ms (default 100ms)
- **Noice**: Cmdline-only mode, health checker disabled
- `updatetime`: 200ms (default 4000ms)
- `timeoutlen`: 300ms (default 1000ms)
- `synmaxcol`: 300 (skip long lines)
- `scrolloff`: 10
- All language providers disabled (Python, Ruby, Perl, Node)
- Ghostty terminal optimizations (24-bit color, undercurl, cursor shapes, synchronized output)
- tmux extended keys enabled for proper `<C-i>`/`<Tab>` distinction
- Custom paste handler decodes CSI-encoded newlines for tmux + Ghostty compatibility
