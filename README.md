# My personal Neovim Configuration

A performance-optimized [LazyVim](https://github.com/LazyVim/LazyVim) setup for Full-Stack development and DevOps workflows.



## Features

- File navigation with oil.nvim (floating explorer) and Snacks.picker
- Autocompletion via blink.cmp with LSP, snippets, path, and buffer sources
- Diagnostics navigation and error fixing with custom shortcuts
- Todo comments tracking with quick navigation
- Code formatting with prettierd
- Language support: TypeScript, JavaScript, Python, Go, Ruby, Lua, Rust, C/C++

## Disabled Plugins

Plugins disabled from LazyVim defaults for performance:

| Plugin | Reason |
|--------|--------|
| `noice.nvim` | UI overhead |
| `nvim-lint` | TypeScript LSP sufficient |
| `gitsigns.nvim` | Heavy in large repos |
| `bufferline.nvim` | Constant recalculation |
| `persistence.nvim` | Session micro-freezes |
| `mini.ai` | Not needed |
| `treesitter-context` | Heavy in large repos |
| `friendly-snippets` | Unsupported transform syntax |
| `flash.nvim` | Disabled |
| `copilot.lua` | Disabled |

## Completion (blink.cmp)

| Key | Action |
|-----|--------|
| `<C-n>` / `<C-p>` | Navigate items |
| `<CR>` | Accept completion |
| `<C-i>` | Toggle completion menu |
| `<C-e>` | Close menu |
| `<C-h>` | Toggle documentation |
| `<Tab>` / `<S-Tab>` | Passthrough (indent/outdent) |

- **Sources**: Snippets (priority 200) > LSP (100) > Path > Buffer
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
- Custom `gd` filters out `node_modules` definitions

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

### Diagnostics

| Key | Action |
|-----|--------|
| `gi` | Show line diagnostics |
| `ge` | Next error |
| `gp` | Previous error |

### Navigation

| Key | Action |
|-----|--------|
| `gf` | Go to function start |
| `gh` | Go to function end |
| `[f`/`]f` | Navigate functions (textobjects) |

### Treesitter Text Objects

`af`/`if` (function), `ac`/`ic` (class), `aa`/`ia` (parameter)

### Picker (Snacks)

| Key | Action |
|-----|--------|
| `<leader><leader>` | Smart finder (recent + buffers) |
| `<leader>ff` | Find files (root) |
| `<leader>fi` | Find files (current dir) |
| `<leader>sl` | Grep current file |

## Snippets

VSCode JSON format in `snippets/` using blink.cmp built-in provider (not LuaSnip).

- **es6-javascript.json** — Console, imports, exports, arrow functions, destructuring, loops, async/await, error handling
- **typescriptreact.json** — React hooks (`useState`, `useEffect`, `useRef`, `useMemo`, `useCallback`), JSX helpers

## Performance Tuning

- **Comment detection**: Cached on `CursorMovedI` (not every keystroke)
- **vtsls debounce**: 200ms (default 100ms)
- **Snippets**: Async processing enabled
- **Lualine refresh**: 500ms (default 100ms)
- `updatetime`: 200ms (default 4000ms)
- `timeoutlen`: 300ms (default 1000ms)
- `synmaxcol`: 300 (skip long lines)
- `scrolloff`: 10
- All language providers disabled (Python, Ruby, Perl, Node)
- Ghostty terminal optimizations (24-bit color, undercurl, cursor shapes, synchronized output)
- tmux extended keys enabled for proper `<C-i>`/`<Tab>` distinction
