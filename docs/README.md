# Neovim Config

Performance-optimized [LazyVim](https://github.com/LazyVim/LazyVim) setup for full-stack development.

## Core Stack

| Category | Plugin |
|----------|--------|
| Completion | blink.cmp (LSP, snippets, path, buffer) |
| AI | Avante.nvim (Copilot), copilot-lsp (inline + NES) |
| File nav | Snacks.picker, oil.nvim |
| Git | diffview.nvim, custom blame floats |
| Search | grug-far (project-wide search & replace) |
| Multi-cursor | vim-visual-multi |
| Folding | nvim-ufo (treesitter + indent) |
| Formatting | prettierd |
| Theme | tokyonight (night) |

## Key Bindings

### Navigation

| Key | Action |
|-----|--------|
| `<leader><leader>` | Smart finder (recent + buffers + files) |
| `<leader>ff` | Find files (root) |
| `<leader>fi` | Find files (current dir) |
| `<leader>r` | Toggle explorer |
| `<leader>e` | Oil floating explorer |
| `<leader>sl` | Grep current file |
| `gf` / `gh` | Function start / end (treesitter) |
| `[f` / `]f` | Prev / next function |
| `gi` | Line diagnostics (focusable) |
| `ge` / `gp` | Next / prev error |

### Editing

| Key | Action |
|-----|--------|
| `<Tab>` | NES accept / focus float / hover |
| `<M-d>` | Add next occurrence (multi-cursor) |
| `<M-/>` | Toggle comment |
| `<leader>l` (visual) | Insert log statement |
| `zm` / `zn` | Toggle folds (keep current / all) |

### AI & Copilot

| Key | Action |
|-----|--------|
| `<C-l>` | Accept Copilot suggestion |
| `<leader>am` | Select Avante model |
| `<leader>ag` | Switch to Haiku 4.5 |
| `<leader>af` / `<leader>at` | Toggle files / todos panel |

### Git

| Key | Action |
|-----|--------|
| `<leader>gd` | Toggle diff view |
| `<leader>gw` | Git who (compact blame) |
| `<leader>gb` | Git blame (full diff) |
| `<leader>gs` | Stage hunk |

### General

| Key | Action |
|-----|--------|
| `<C-s>` | Save |
| `<C-->` | Terminal (right) |
| `<leader>L` | Restart Neovim |
| `<leader>R` | Lazy log |
| `<leader>sF` / `<leader>sf` | Search & replace (project / file) |

## Snippets

VSCode JSON format in `snippets/` — ES6 patterns, React hooks, JSX helpers.

## Performance

- Heavy plugins disabled: bufferline, nvim-lint, persistence, mini.ai, treesitter-context
- Lualine throttled to 500ms, gitsigns 800ms, vtsls 200ms debounce
- Comment detection cached (treesitter query only on idle)
- Noice restricted to cmdline UI only
