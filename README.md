# My personal Neovim Configuration

A performance-optimized [LazyVim](https://github.com/LazyVim/LazyVim) setup for Full-Stack development and DevOps workflows.

## Features

- File navigation with oil.nvim (floating explorer) and Snacks.picker
- Autocompletion via blink.cmp with LSP, snippets, path, and buffer sources
- Copilot inline suggestions + NES (Native Edit Suggestions) via copilot-lsp
- AI chat assistant with Avante.nvim (Copilot provider)
- Multi-cursor editing with vim-visual-multi (VSCode/Zed-style keybindings)
- Git hunks with gitsigns, full diff viewer with diffview.nvim
- Git blame with floating window previews (compact and full-diff views)
- Treesitter-powered function navigation, text objects, and folding (nvim-ufo)
- Search and replace with grug-far (project-wide, per-file, and rename)
- Language-aware log statement insertion for JS/TS/Python/Go/Rust/Lua/C++
- Diagnostics navigation and error fixing with custom shortcuts
- Todo comments tracking with extended keywords and quick navigation
- Code formatting with prettierd
- Language support: TypeScript, JavaScript, Python, Go, Ruby, Lua, Rust, C/C++

## Disabled Plugins

Plugins disabled from LazyVim defaults for performance:

| Plugin | Reason |
|--------|--------|
| `nvim-lint` | TypeScript LSP sufficient |
| `bufferline.nvim` | Constant recalculation |
| `persistence.nvim` | Session micro-freezes |
| `mini.ai` | Not needed |
| `mini.surround` | Replaced by vim-surround |
| `treesitter-context` | Heavy in large repos |
| `friendly-snippets` | Unsupported transform syntax |
| `flash.nvim` | Disabled |
| `vim-matchup` | Disabled |
| `nvim-spectre` | Replaced by grug-far |

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

### NES (Native Edit Suggestions)

Copilot-LSP powered inline edits with 300ms debounce.

| Key | Mode | Action |
|-----|------|--------|
| `<Tab>` | n/i | Accept NES edit (falls through to hover/indent if no edit pending) |
| `<Esc>` | n | Dismiss NES edit |

## Completion (blink.cmp)

| Key | Action |
|-----|--------|
| `<C-n>` / `<C-p>` | Navigate items |
| `<CR>` | Accept completion |
| `<C-i>` | Toggle completion menu |
| `<C-e>` | Close menu |
| `<C-h>` | Toggle documentation |
| `<Tab>` / `<S-Tab>` | Passthrough (NES accept / indent / outdent) |

- **Sources**: LSP, Snippets (equal priority 100), Path, Buffer
- **Sorting**: Exact prefix matches first, then score, then sort_text (VSCode-like behavior)
- **Ghost text**: Disabled
- Completions disabled in comments (cached detection) and Avante buffers
- Documentation auto-shows after 200ms
- Emmet bracket-only completions filtered out
- Async snippet processing enabled

## AI Assistant (Avante.nvim)

Uses Copilot as provider for AI chat within Neovim.

## Multi-Cursor (vim-visual-multi)

| Key | Action |
|-----|--------|
| `<M-d>` | Add next occurrence (like VSCode Cmd+D) |
| `<M-L>` | Select all occurrences (like VSCode Cmd+Shift+L) |
| `<M-]>` | Skip current match |

Cursor restores to original position on exit. Cleans up buffer-local `<CR>` keymap on exit to prevent blink.cmp conflicts.

## LSP

| Server | Config |
|--------|--------|
| `vtsls` | TypeScript, 75ms debounce, 8GB heap, auto-imports from package.json disabled |
| `emmet_ls` | HTML only (not TSX/JSX) |
| `eslint` | Disabled |

- Inlay hints disabled
- Diagnostics: `update_in_insert = false`, `severity_sort = true`, rounded borders, 80-char max width
- Custom `gd` filters out `node_modules` and skips import-line definitions
- Document color highlights disabled (prevents tailwindcss color swatches)

## Git

### Gitsigns

Inline gutter diff signs with 800ms debounce (performance-tuned).

| Key | Mode | Action |
|-----|------|--------|
| `grn` / `grp` | n | Next / previous hunk |
| `<leader>gp` | n | Preview hunk |
| `<leader>gs` | n/v | Stage hunk |
| `<leader>gr` | n/v | Reset hunk |
| `<leader>gS` | n | Stage buffer |
| `<leader>gR` | n | Reset buffer |

### Diffview

Full diff viewer (like VSCode Source Control panel).

| Key | Action |
|-----|--------|
| `<leader>gd` | Toggle diff view |
| `<leader>gl` | File history (current file) |
| `<leader>gL` | File history (repo) |

### Git Blame

| Key | Action |
|-----|--------|
| `<leader>gw` | Git Who — compact blame info (author, date, message) in floating window |
| `<leader>gb` | Git Blame Line — full commit diff in floating window |

## Formatting

`prettierd` for JS, TS, JSX, TSX, JSON, HTML, CSS, SCSS, Markdown, YAML, GraphQL. Falls back to `~/.config/prettier/.prettierrc` when no project config exists.

## File Explorer (oil.nvim)

- `<leader>e` toggles floating explorer (80% width/height)
- Custom dark backdrop overlay (60% opacity)
- `q` / `<Esc>` to close

## Folding (nvim-ufo)

Treesitter + indent based folding with virtual text line count.

| Key | Action |
|-----|--------|
| `zR` | Open all folds |
| `zM` | Close all folds |
| `zK` | Peek folded lines |
| `zm` | Toggle all folds (keep current function open) |
| `zn` | Toggle all folds (including current) |
| `<leader>uo` | Toggle fold column |

Enhanced status column via `statuscol.nvim` with fold indicators, line numbers, and signs.

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
| `<M-f>` | n | Highlight word under cursor |
| `<C-d>/<C-u>` | n/v | Half-page scroll (recentered) |
| `<C-f>/<C-b>` | n/v | Full-page scroll (recentered) |
| `<C-s>` | n/i | Save file |
| `<Tab>` | n | NES accept / focus float / LSP hover |
| `<M-i>` | i/n | Signature help (Option+i) |
| `<leader>l` | v | Insert language-aware log statement |
| `<leader>R` | n | Restart Neovim |

### Terminal

| Key | Action |
|-----|--------|
| `<C-->` | Toggle terminal (right side, 30% width) |
| `<Esc>` (terminal mode) | Exit terminal mode |

### Window Resize

| Key | Action |
|-----|--------|
| `<S-Up>/<S-Down>` | Increase/decrease window height |
| `<S-Left>/<S-Right>` | Decrease/increase window width |

### Diagnostics

| Key | Action |
|-----|--------|
| `gi` | Show line diagnostics (focusable float) |
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
| `<leader>sF` | Search & replace (project, smart file filter) |
| `<leader>sf` | Search & replace in current file |
| `<leader>sR` | Rename word under cursor (project) |
| `<leader>sr` | Rename word under cursor (file) |

### Todo Comments

Extended keywords: TODO, PERF, REFACTOR, HACK, WARN, NOTE, TEST, ISSUE.

| Key | Action |
|-----|--------|
| `<leader>td` | Jump to next todo |
| `<leader>st` | Search todos (todo/fix/bug/issue) |
| `<leader>sT` | Search all todo keywords |

### Surround (vim-surround)

Classic keymaps: `ys` (add), `ds` (delete), `cs` (change), `S` (visual).

## Snippets

VSCode JSON format in `snippets/` using blink.cmp built-in provider (not LuaSnip).

- **es6-javascript.json** — Console, imports, exports, arrow functions (`af`, `afa`), named functions (`fa`, `faa`), anonymous functions (`nfa`, `nfaa`), destructuring, loops, async/await, error handling
- **typescriptreact.json** — React hooks (`useState`, `useEffect`, `useRef`, `useMemo`, `useCallback`), JSX helpers

## Performance Tuning

- **Comment detection**: Cached via `CursorHoldI` (treesitter query only on idle, not every keystroke)
- **vtsls debounce**: 50ms
- **Copilot debounce**: 75ms (inline), 500ms (NES)
- **Gitsigns debounce**: 800ms
- **Snippets**: Async processing enabled
- **Lualine refresh**: 500ms (default 100ms)
- **Noice**: Cmdline-only mode, health checker disabled
- `updatetime`: 200ms (default 4000ms)
- `timeoutlen`: 300ms (default 1000ms)
- `synmaxcol`: 300 (skip long lines)
- `scrolloff`: 15
- All language providers disabled (Python, Ruby, Perl, Node)
- Ghostty terminal optimizations (24-bit color, undercurl, cursor shapes, synchronized output)
- tmux extended keys enabled for proper `<C-i>`/`<Tab>` distinction
- Custom paste handler decodes CSI-encoded newlines for tmux + Ghostty compatibility
- Auto-clear command line messages after 2s of inactivity
