<div align="center">

# Neovim Config

**A performance-optimized, custom-tailored [LazyVim](https://github.com/LazyVim/LazyVim) setup for full-stack development.**

*Reads and navigates large codebases like an IDE — and keeps every keystroke instant.*

`~40ms cold start` · `solarized-osaka` · `version-frozen`

</div>

---

## Philosophy

One rule governs everything here: **nothing expensive runs on the hot path.**
A feature earns its place only if it costs effectively `0ms` per keystroke,
cursor move, and redraw. Polish and convenience never come at the price of
snappiness.

That principle is enforced, not just intended — `:Lazy update/sync/restore` is
blocked at the Lua level, and a written editing policy keeps future changes from
quietly regressing speed.

> See [`rules.md`](rules.md) for the freeze policy and
> [`notes/safe-config-editing-guide.md`](notes/safe-config-editing-guide.md)
> for the performance rules every change is held to.

---

## Highlights

What makes this feel less like vanilla Neovim:

| | |
|---|---|
| 🖱️ **Hover docs on mouse-over** | LSP documentation appears when the pointer rests on a symbol (Zed/WebStorm parity), behind a throttled handler that's free while you type. |
| 🤖 **AI inline + Next Edit Suggestions** | `copilot.lua` ghost text plus `copilot-lsp` NES — jump-and-apply multi-line edits with `<Tab>`, coexisting with the completion menu. |
| 📋 **AI prompt-copy system** | `<leader>ac…` copies a context-aware prompt (commit, codebase analysis, explain, refactor, review) to the clipboard for an external CLI agent. |
| 📌 **Persistent quickfix curation** | Mark lines with `<leader>m` while reading code; the list survives restarts, scoped per project. |
| 🗂️ **Symbols outline** | `<leader>cs` opens an IDE-style structure pane that follows your cursor. |
| 🔍 **In-buffer git blame** | `<leader>gw` / `<leader>gb` show compact and full blame as floats, without leaving the file. |

---

## Core Stack

| Category | Plugin |
|----------|--------|
| **Completion** | blink.cmp — LSP · snippets · path · buffer |
| **AI** | copilot.lua (inline) + copilot-lsp (NES) + prompt-copy system |
| **File nav** | Snacks — picker · explorer · dashboard · terminal · oil.nvim (float) |
| **Code nav** | Trouble (symbols outline + quickfix views) · treesitter textobjects |
| **Git** | neogit + diffview.nvim + custom blame floats |
| **Search** | grug-far — project/file search-replace & rename |
| **Multi-cursor** | vim-visual-multi |
| **Folding** | nvim-ufo — treesitter + indent, async |
| **Formatting** | conform.nvim → prettierd |
| **UI** | lualine · noice (cmdline only) · fidget · which-key |
| **Theme** | solarized-osaka |

---

## Key Bindings

> Leader is `<Space>`. `<M-…>` keys are sent by the terminal (Ghostty) from the
> macOS Cmd/Option layer.

<details open>
<summary><b>Navigation &amp; search</b></summary>

| Key | Action |
|-----|--------|
| `<leader><leader>` | Smart finder (recent + buffers + files) |
| `<leader>ff` · `<leader>fi` | Find files — root · current dir |
| `<leader>fp` | Switch project |
| `<leader>r` | Toggle Snacks explorer |
| `<leader>e` | Oil floating file manager |
| `<leader>sl` | Grep within current file |
| `<leader>sf` · `<leader>sF` | Search & replace — project · current file |
| `<leader>sr` · `<leader>sR` | Rename word under cursor — file · project |
| `gd` | Goto definition (skips node_modules & re-imports) |
| `gf` · `gh` | Function start · end (treesitter) |
| `[f` · `]f` | Prev · next function |
| `<M-f>` | Highlight word under cursor |

</details>

<details>
<summary><b>Code navigation — Trouble &amp; quickfix</b></summary>

| Key | Action |
|-----|--------|
| `<leader>cs` | Symbols outline (press `a` inside to include variables) |
| `<leader>ce` · `<leader>cE` | Quickfix · location list (Trouble) |
| `<leader>m` | Mark line/selection into quickfix — persists across restarts |
| `<leader>cx` | Clear quickfix list |
| `<leader>bu` | List unsaved buffers (jump / save) |
| `gi` | Line diagnostics (focusable) |
| `ge` · `gp` | Next · prev error |

</details>

<details>
<summary><b>Editing</b></summary>

| Key | Action |
|-----|--------|
| `<Tab>` | Accept NES → focus float → jumplist forward |
| `<M-d>` | Add next occurrence (multi-cursor) |
| `<M-/>` | Toggle comment (line / selection) |
| `ys` · `ds` · `cs` · `s` (visual) | Surround |
| `zm` · `zn` | Toggle all folds — keep current open · fold all |
| `zR` · `zM` · `zv` | Open all · close all · toggle function folds |
| `K` · `<M-i>` | Hover docs · signature help |

</details>

<details>
<summary><b>AI &amp; Copilot</b></summary>

| Key | Action |
|-----|--------|
| `<C-l>` | Accept suggestion + trigger next |
| `<C-j>` | Trigger / cycle suggestion |
| `<C-k>` · `<leader>ad` | Toggle Copilot suggestions |
| `<M-w>` · `<M-l>` | Accept word · line |
| `<M-]>` · `<M-[>` | Cycle suggestions |
| `<leader>ab` · `<C-b>` | Toggle blink completion menu |
| `<leader>as` | Copy current file path (for CLI agents) |
| `<leader>acc` · `aca` · `ace` | Prompt — commit · codebase analysis · explain file |
| `<leader>acs` · `acd` (visual) | Prompt — explain symbol · explain selection |
| `<leader>acf` · `acr` | Prompt — refactor · pre-commit review |

</details>

<details>
<summary><b>Git</b></summary>

| Key | Action |
|-----|--------|
| `<leader>gd` | Toggle diff view |
| `<leader>gl` · `<leader>gL` | File history — current file · repo |
| `<leader>gf` | File history (open commit diff on enter) |
| `<leader>gw` · `<leader>gb` | Git who (compact blame) · blame line (full diff) |
| `<leader>gn` · `<leader>gN` | Neogit status · log |
| `<leader>gc` · `gp` · `gP` | Neogit commit · pull · push |

</details>

<details>
<summary><b>General</b></summary>

| Key | Action |
|-----|--------|
| `<C-s>` | Save |
| `<C-->` | Terminal (right split) |
| `<C-d>` · `<C-u>` | Half-page scroll + recenter |
| `<C-e>` · `<C-y>` | Scroll popup, else viewport |
| `<leader>uH` | Toggle mouse-hover docs |
| `<leader>M` | Mason (toggle) |
| `<leader>L` · `<leader>R` | Restart Neovim · Lazy log |

</details>

---

## Performance

The whole point. What's tuned, and what's off on purpose.

**Killed on the hot path**

- `matchparen` disabled — no per-cursor-move highlight scan
- Snacks `words` · `scope` · `indent` · `scroll` · `animate` all off
- treesitter-context off; treesitter highlight stops above 100KB files
- LSP semantic tokens · `document_color` · inlay hints off; `update_in_insert = false`
- lualine throttled to 1000ms; git-diff component removed from the statusline
- LSP `debounce_text_changes = 300ms` applied globally through `vim.lsp.config("*", ...)`
- noice restricted to the cmdline popup; python/ruby/perl/node providers disabled

**Disabled by decision** — don't re-add without a reason:
> gitsigns · bufferline · flash · harpoon · spectre · avante · sidekick ·
> nvim-lint · persistence · mini.\* · render-markdown · friendly-snippets

**Version freeze** — `:Lazy update/sync/restore` is blocked at the Lua level
(`lua/config/lazy-freeze.lua`). Unlock one session with `NVIM_LAZY_UNLOCK=1 nvim`.

---

## Snippets

VSCode JSON format in `snippets/`, served through blink.cmp's built-in snippet
provider (not LuaSnip) — JS/TS, React, Go, and Python helpers. `package.json`
maps each file to its filetype.

---

## Layout

```
init.lua            bootstrap
lua/config/         options · keymaps · autocmds · lazy · mouse-hover · ai-prompts
lua/plugins/        one file per plugin (disabled specs kept for reference)
lua/colorschemes/   active theme (config.lua) + reference-only alternates
snippets/           VSCode-format snippets
notes/              working guides — safe-editing · reading codebases · journal
docs/               CHANGELOG · agent instructions
```

---

## Requirements

Neovim **0.12+**, a Nerd Font, `ripgrep` & `fd` (pickers/grep), `prettierd`
(formatting, via Mason), and a GitHub Copilot subscription for the AI features.
Tuned for the [Ghostty](https://ghostty.org) terminal on macOS; works elsewhere,
but some `<M-…>`/`<D-…>` keymaps assume Ghostty's key encoding.
