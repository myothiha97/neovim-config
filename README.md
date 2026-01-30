# Myothiha's Neovim Configuration

A performance-optimized [LazyVim](https://github.com/LazyVim/LazyVim) setup for Full-Stack development and DevOps workflows.

## Extras

- `lazyvim.plugins.extras.coding.mini-surround`
- `lazyvim.plugins.extras.formatting.prettierd`
- `lazyvim.plugins.extras.lang.json`
- `lazyvim.plugins.extras.lang.typescript`

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

- **Accept**: `Enter` (Tab/S-Tab unbound)
- **Navigate**: `Ctrl-n` / `Ctrl-p`
- **Ghost text**: Disabled
- **Sources**: LSP (priority 100) > Snippets (90) > Path > Buffer
- Completions disabled in comments and Avante buffers
- Emmet bracket-only completions filtered out

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

- Lualine refresh: 500ms (default 100ms)
- `updatetime`: 200ms (default 4000ms)
- `timeoutlen`: 300ms (default 1000ms)
- `synmaxcol`: 300 (skip long lines)
- `scrolloff`: 10
- All language providers disabled (Python, Ruby, Perl, Node)
- Ghostty terminal optimizations (24-bit color, undercurl, cursor shapes, synchronized output)
