# Multi-Language Support

## Goal
Bring the config from "TS/React-tuned" to **production-grade** support across the
languages I develop in — so each language has the full loop (LSP, format, lint,
debug, test, folds), not just syntax highlighting. Do it without breaking the
existing TS experience or the performance budget.

> Do this in a freeze batch (`NVIM_LAZY_UNLOCK=1 nvim`). Prefer LazyVim lang
> extras (`:LazyExtras`) — each wires LSP + treesitter + formatter (+ DAP) in one
> managed, low-maintenance entry.

## Production-readiness tracker

Legend: ✅ done · 🔶 partial / verify · ⬜ todo · 💤 deferred (future)

| Language | LSP | Format | Lint | Debug (DAP) | Test | Folds | Overall |
|----------|-----|--------|------|-------------|------|-------|---------|
| JS/TS/React | ✅ vtsls | ✅ prettierd | ➖ (eslint off) | 🔶 js-debug | ⬜ | ✅ | **Daily-driver ready** |
| Go | ✅ gopls | ✅ gofumpt/goimports | 🔶 golangci-lint | 🔶 delve | ⬜ neotest-go | ✅ | **Near-complete** |
| Python | ✅ basedpyright | 🔶 ruff | ✅ ruff | 🔶 debugpy | ⬜ neotest-python | ✅ | **Near-complete** |
| Bash | ⬜ bashls | ⬜ shfmt | ⬜ shellcheck | ➖ | ➖ | ➖ | **Deferred** |
| Lua | ✅ lua_ls | 🔶 stylua | ➖ | ➖ | ➖ | ✅ | Ready (install stylua) |
| JSON | ✅ jsonls | ✅ prettierd | ➖ | ➖ | ➖ | ✅ | Ready |
| Markdown | ➖ | ✅ prettierd | ➖ | ➖ | ➖ | ➖ | Ready (render-markdown off by choice) |
| Rust | 💤 rustaceanvim | 💤 rustfmt | 💤 | 💤 codelldb | 💤 | ✅ | **Dormant — needs rustup** |
| C | 💤 clangd | 💤 clang-format | ➖ | 💤 codelldb | ➖ | ⬜ add fold | **Future — not enabled** |

## DONE — finalization batch (2026-06-02)

- [x] **Go** — verified complete: gopls + gofumpt + goimports + delve present.
- [x] **Python** — `lang.python` extra; LSP pinned to **basedpyright** via
  `vim.g.lazyvim_python_lsp` in `options.lua`; `openFilesOnly` diagnostics;
  venv-selector.nvim installed.
- [x] **Rust** — `lang.rust` extra enabled (rustaceanvim + crates.nvim); left
  **dormant/ready** — activates once the system toolchain exists (see below).
- [x] **Bash** — left deferred. LSP/format/lint still TODO (below).
- [x] **`~/.git` root guard** — `$HOME` is a git repo, which made loose .py/.go
  files treat all of `$HOME` as the workspace (10s+ enumeration). gopls now
  roots on Go module markers (go.mod/go.work), then the file's dir.
  basedpyright and ruff root on Python/ruff project markers, fall back to `.git`
  only when it is not `$HOME`, then the file's dir. Verified against a temp
  marker project and loose `$HOME` files.
- [x] **Folding gap** — added `go/python/rust` to `treesitter_folds` in
  `lua/plugins/folding.lua`.
- [x] **Shared LSP config** — per-server `debounce_text_changes` replaced by one
  native wildcard `vim.lsp.config("*", { flags = … })`. Applies to every server.
  Confirmed vtsls/TS behavior unchanged (no regression).

## Remaining for full production support

### Bash — finish the loop (only indent guides done)
- [ ] Enable **bashls** (`bash-language-server`, already in Mason) in `lsp.lua` servers.
- [ ] Add `sh`/`bash` → `shfmt` to conform (`shfmt` already in Mason).
- [ ] Wire **shellcheck** (already in Mason) — bashls integrates it, or via nvim-lint.

### Python — verify + production niceties
- [ ] Confirm `ruff` finished installing (`:Mason`) and **format-on-save** works.
- [ ] **venv workflow** — `venv-selector.nvim` is installed; confirm `:VenvSelect`
  picks the project interpreter so basedpyright + debugpy use the right env.
  (Critical for real projects with virtualenvs, e.g. `task-manager-api/venv`.)
- [ ] Verify **debugpy** debugging (nvim-dap-python) on a real script.
- [ ] Optional: `neotest-python` for in-editor test running.

### Go — verify + production niceties
- [ ] Confirm **golangci-lint** is wired and reporting (installed via extra).
- [ ] Verify **delve** debugging works (set breakpoint, step).
- [ ] Optional: `neotest-go` for test running.

### Rust — system dependency (NOT a config task)
- [ ] Install toolchain: `rustup` → `cargo`, `rustc`, `rustup component add rust-analyzer`.
  Config is ready; rustaceanvim activates once the toolchain is on PATH. Then
  verify hover/diagnostics/format/`codelldb` debug.

### C — future, when needed
- [ ] Enable `lang.clangd` extra (clangd + clang-format).
- [ ] Add `c` (and `cpp`) to `treesitter_folds` in `folding.lua`.

### Cross-cutting (production workflow)
- [ ] **Debugging** — `dap.core` is installed; settle on a consistent keymap
  cluster + verify per-language adapters (delve/debugpy/codelldb).
- [ ] **Testing** — decide whether to adopt `neotest` + per-language adapters
  (none installed yet). Keep it lazy-loaded if so.
- [ ] Spot-check **rename / references / code actions** per language (LSP defaults).

### Verify checklist (per language, on first real use)
- [ ] Hover (`K`), signature (`<M-i>`), goto-def (`gd`), diagnostics.
- [ ] Format on save; lint surfaces issues.
- [ ] Folds (`zm`/`zn`/`zv`); large-file guards still apply.
- [ ] Startup still ~40ms; no new per-keystroke cost (see
  `notes/safe-config-editing-guide.md`).

## Notes
- Overlaps with `todos/config-refactoring.md` (unifying LSP/folding/diagnostics).
  Consider doing the refactor and remaining language work in the same batch.
- Don't enable extras for languages not actually used — each adds Mason tools and
  startup surface.
- `~/.git` is the root cause of the workspace-enumeration class of bugs; the
  config now guards against it, but removing/relocating that repo would eliminate
  the whole class for every tool.
