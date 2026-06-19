# Production Stack Readiness — Gap Closure Report

> Generated 2026-06-19 · priorities refined 2026-06-19. Review-only artifact —
> **no config was edited to produce this.**
> Supersedes/refines the FE + DevOps rows of [`multi-language-support.md`](./multi-language-support.md).
> Execute (if at all) as ONE freeze-batch, then re-lock. See "Execution" at the bottom.

## Purpose

Assess whether the **frozen** config is production-capable for the real target stack
and give a precise, reviewable diff + checklist to close the gaps — without breaking
the TS/React tuning or the performance budget.

**Target stack — refined priorities (2026-06-19; horizon = rest of 2026):**

> "Current" here means **the remainder of 2026** — not just this week. So the batch below
> is sized to cover the whole year's work, and every "deferred" item (Vue/Svelte/Angular,
> Rust/C/C++/Ruby) is a **2027+ concern**. This aligns with the freeze: one DevOps batch
> now buys a clean, untouched config for the rest of the year.

1. **Node.js fullstack — HIGH.** Web (primary) + mobile via React Native (needed, lower
   priority) + desktop via Electron (very low / future) + Node.js backend.
2. **Go — HIGH.** Backend + cloud-native services.
3. **DevOps — HIGH.** Multi-server config, CI/CD, automation, infra (Docker, Kubernetes/CI
   YAML, Terraform/Helm).
4. **System / scripting — LOW.** Bash and C for system work + automation.
- **Main stack right now: Go + Node.js + DevOps.**
- Python = secondary but **real for DevOps** (it's a primary DevOps/automation/IaC-scripting
  language) — already production-ready (basedpyright + ruff + debugpy + neotest-python +
  venv-selector), no action needed.
- Frontend frameworks (Vue/Svelte/Angular) = deferred, not actively coded now.

**Key consequence of these priorities:** the entire main stack except DevOps is **already
done**. Go and Node need nothing (Go just wants `golangci-lint` on PATH). So the actionable
batch reduces to **one DevOps batch + one `brew` command** — everything else is deferred.

---

## Executive verdict

**The core of your career is already production-ready.** Go, Node, Python, and React all
have the full loop (LSP · format · debug · test · folds). React Native and Electron need
**zero** new tooling — they ride on the `vtsls` TypeScript setup you already tuned.

The freeze itself is **complete and correct** — nothing to build:

| Freeze layer | Mechanism | Status |
|---|---|---|
| Runtime guard | `lua/config/lazy-freeze.lua` blocks `:Lazy update/sync/restore` unless `NVIM_LAZY_UNLOCK=1` | ✅ wired |
| Version pin | `lazy-lock.json` (64 plugins, exact commits), git-tracked | ✅ |
| Written policy | `notes/config-freeze-policy.md` + `rules.md` | ✅ |

Remaining work, ranked by your priorities:

1. **DevOps (HIGH)** — YAML lacks schema awareness; Docker/Terraform/Helm servers not installed.
2. **Bash + C (LOW)** — Bash LSP attaches but format unwired; C entirely unconfigured.
3. **Vue / Svelte / Angular (DEFERRED)** — secondary FE, not actively coded now; install when a project lands.

So the actionable batch is effectively **just DevOps** (+ a 2-line Bash tweak if you want it).
Everything below is a la carte. Do all, some, or none — then re-lock.

---

## Current-state matrix (verified against live Mason + LazyVim behavior)

Mason-installed (live): `vtsls, gopls, basedpyright, ruff, gofumpt, goimports, delve,
debugpy, js-debug-adapter, codelldb, prettierd, yaml-language-server,
bash-language-server, tailwindcss-language-server, css-lsp, emmet-ls, taplo, shfmt,
shellcheck, stylua, json-lsp, lua-language-server`.

> Note: LazyVim sets `mason-lspconfig` `automatic_enable`, so **every installed server
> above auto-attaches on its filetype** even if it's not in your `lsp.lua` `servers`
> table. That means `yamlls`, `bashls`, `cssls`, `tailwindcss` are **already active** —
> the old "enable bashls" TODO is stale.

| Target | Priority | LSP | Format | Lint | Debug | Test | Status |
|---|---|---|---|---|---|---|---|
| **Node.js** | HIGH | vtsls | prettierd | (TS) | js-debug | vitest | ✅ Production-ready |
| **React** (web) | HIGH | vtsls + tailwind + emmet | prettierd | (TS) | js-debug (Chrome) | neotest-vitest | ✅ Daily-driver tuned |
| **React Native** (mobile) | MED | vtsls | prettierd | (TS) | js-debug¹ | vitest | ✅ Ready (no extra tooling) |
| **Electron** (desktop) | LOW | vtsls | prettierd | (TS) | js-debug (Node+Chrome) | vitest | ✅ Ready (no extra tooling) |
| **Go** | HIGH | gopls | gofumpt/goimports | golangci-lint² | delve | neotest-golang | ✅ Production-ready |
| **Python** | MED | basedpyright | ruff | ruff | debugpy | neotest-python | ✅ Production-ready |
| **YAML** (k8s/CI) | HIGH | yamlls (auto) | prettierd | — | — | — | 🔶 No schema awareness |
| **Docker** | HIGH | ✗ none | — | — | — | — | ⬜ GAP |
| **Terraform** | HIGH | ✗ none | — | — | — | — | ⬜ GAP |
| **Helm** | HIGH | ✗ none | — | — | — | — | ⬜ GAP |
| **Bash** | LOW | bashls (auto) | ✗ no shfmt wired | shellcheck (via bashls) | — | — | 🔶 Format gap only |
| **C** | LOW | ✗ none | ✗ none | — | codelldb (present) | — | ⬜ GAP (not configured) |
| **Vue** | DEFER | ✗ none | prettierd | — | — | — | 💤 Deferred (not active) |
| **Svelte** | DEFER | ✗ none | prettierd | — | — | — | 💤 Deferred (not active) |
| **Angular** | DEFER | ✗ none | prettierd | — | — | — | 💤 Deferred |
| **Lua / JSON / TOML** | infra | lua_ls / jsonls / taplo | stylua / prettierd | — | — | — | ✅ Ready |

¹ RN device/Metro debugging happens outside Neovim; the editor side (TS intellisense) is complete.
² golangci-lint is **not on PATH** and not in Mason — wired via the Go extra but the binary
must exist. `brew install golangci-lint` to activate Go linting.

---

## What is already perfect — DO NOT TOUCH

- `lua/plugins/lsp.lua` — the `$HOME/.git` root guards (gopls/basedpyright/ruff),
  semantic-token disable, `gd` node_modules filter, vtsls memory/watch tuning. Load-bearing
  and subtle; leave it alone.
- `lua/plugins/blink-cmp.lua` — completion + the `vim.b.completion` toggle. Documented as
  fragile; any change risks the suggestion pipeline you protect.
- Performance disables (noice/nvim-lint/persistence/mini.*/treesitter-context).

The changes below are **purely additive** (new lang extras + 2 small conform lines).
None touch the hot path or the files above.

---

## Gap-closure plan (precise diffs) — ordered by your priorities

Everything uses **LazyVim lang extras** — the ecosystem-standard, low-maintenance path
(each wires LSP + treesitter + formatter (+DAP) in one managed entry). Matches your
"convention over personal-ease" preference and keeps the knowledge portable.

### PRIORITY 1 (HIGH) — DevOps

Your single highest-value gap, and a HIGH-priority area. Enable via `:LazyExtras`:

| Extra | Adds | Mason tools pulled |
|---|---|---|
| `lazyvim.plugins.extras.lang.yaml` | **SchemaStore** → schema-aware YAML: k8s manifests, GitHub Actions, compose completion + validation | (uses existing `yaml-language-server`) |
| `lazyvim.plugins.extras.lang.docker` | dockerls + docker-compose LSP, Dockerfile/compose ft | `dockerfile-language-server`, `docker-compose-language-service`, `hadolint` |
| `lazyvim.plugins.extras.lang.terraform` | terraform-ls, tf/hcl ft | `terraform-ls` (+ `tflint` optional) |
| `lazyvim.plugins.extras.lang.helm` | helm-ls, `.tpl`/chart ft | `helm-ls` |

- **The YAML extra is the highest-value single change** — it turns plain YAML editing into
  k8s/CI intellisense, the thing you actually feel missing across CI/CD + infra + cloud-native Go.
- All are **filetype-lazy** — load only when you open a Dockerfile/`.tf`/`.yaml`/chart, so
  startup cost ≈ 0.

### PRIORITY 2 (LOW) — System / scripting (Bash + C)

**Bash** — LSP already attaches; only formatting missing.
**Edit `lua/plugins/formatting.lua`** → add to `formatters_by_ft`:

```lua
sh   = { "shfmt" },
bash = { "shfmt" },
```
- `shfmt` already in Mason. shellcheck diagnostics already surface via `bashls`.
- Verify: `.sh` file → `:LspInfo` shows bash-language-server; `:w` formats.

**C** — currently unconfigured. When you actually start system work in C, enable via
`:LazyExtras` → `lazyvim.plugins.extras.lang.clangd` (clangd + clang-format; `codelldb`
for debugging is already installed). Also add `c` to `treesitter_folds` in
`lua/plugins/folding.lua`. **Defer until a real C task appears** — don't pre-install.

### DEFERRED — Vue, Svelte, Angular (FE frameworks, not actively coded now)

Secondary FE stacks for the Node web side — **not actively coding them today**, so don't
install yet (your "don't enable extras for languages not actually used" rule). Each is a
clean `:LazyExtras` toggle when a real project lands:

| Extra | Adds | Notes |
|---|---|---|
| `lazyvim.plugins.extras.lang.vue` | `vue-language-server` (Volar) + wires `@vue/typescript-plugin` into `vtsls` | ⚠️ Touches vtsls init — when enabled, smoke-test a `.tsx` for regressions before committing. |
| `lazyvim.plugins.extras.lang.svelte` | `svelte-language-server` | Self-contained, clean. |
| `lazyvim.plugins.extras.lang.angular` | `angular-language-server` | Lowest likelihood; heavy, needs project deps. |

### FUTURE — additional languages (don't install until actually used)

Captured for a future batch (noted 2026-06-19). Each is a clean LazyVim extra; the pattern
is identical — unlock, `:LazyExtras`, verify, re-lock. **Do not pre-install** — they add
Mason tools + startup surface for languages you're not writing yet.

| Language | Extra | System dependency | Notes |
|---|---|---|---|
| **Rust** | `lazyvim.plugins.extras.lang.rust` | `rustup` toolchain (`cargo`/`rustc` + `rust-analyzer`) — **not on PATH** | Extra is **already enabled** in `lazyvim.json` but **dormant** — rustaceanvim activates only once the toolchain exists. `codelldb` debug already installed. Just `rustup` away. |
| **C** | `lazyvim.plugins.extras.lang.clangd` | clangd (via Mason) | clangd + clang-format; `codelldb` already present. Add `c` to `treesitter_folds`. (Same entry covers the LOW-priority C work above.) |
| **C++** | `lazyvim.plugins.extras.lang.clangd` | clangd (via Mason) | Same extra as C — enabling clangd covers both. Add `cpp` to `treesitter_folds`. |
| **Ruby** | `lazyvim.plugins.extras.lang.ruby` | a Ruby install (`ruby`/`gem`) on PATH | Wires ruby-lsp/solargraph + rubocop + treesitter. |

> Rust is the cheapest to "activate" — the config is already wired; it's a one-command
> system install away, no nvim edit needed.

---

## Performance budget check

Your #1 rule is zero hot-path cost. These changes are safe:

- Lang extras register **filetype-scoped** lspconfig/treesitter entries. Nothing runs at
  startup for filetypes you don't open; nothing runs per-keystroke.
- SchemaStore (YAML extra) is a static catalog — loaded once when a YAML buffer opens, not
  on the typing path.
- No new `CursorMoved`/`TextChanged` autocmds. No lualine/statusline additions.
- Watch item: the **Vue extra changes vtsls init** — verify TS responsiveness in a large
  `.tsx` post-enable.
- Net startup delta: a handful of lazy specs ≈ negligible. Confirm with `:Lazy profile` /
  `nvim --startuptime` if you want the number.

---

## Execution (when you decide to do it)

The documented freeze-batch flow:

1. **Unlock one session:** `NVIM_LAZY_UNLOCK=1 nvim`
2. **Enable extras:** `:LazyExtras` → toggle Priority 1 (DevOps). Restart when prompted;
   lazy auto-installs plugins, Mason auto-installs tools. (FE extras are deferred — skip.)
3. **Manual edits:** Bash (`formatting.lua`); install golangci-lint for Go linting
   (`brew install golangci-lint`).
4. **Verify per language** (checklist below).
5. **Smoke-test the daily driver:** open a real `.tsx` from a Rezeve portal — hover, `gd`,
   completion, format-on-save — confirm no Vue-extra regression.
6. **Re-lock + commit:** plain `nvim` re-freezes. Commit updated `lazy-lock.json` +
   `lazyvim.json` + `formatting.lua` together. Run `/perf-review` before committing
   (per `docs/CLAUDE.md`).
7. **Mark this file done** and prune overlapping rows from `multi-language-support.md`.

---

## Verify checklist (per target, on first real use)

- [ ] **YAML/k8s/CI** — open a k8s manifest or `.github/workflows/*.yml`: schema completion + validation appear.
- [ ] **Docker** — `Dockerfile` + `docker-compose.yml`: completion/hover; hadolint diagnostics.
- [ ] **Terraform** — `.tf`: terraform-ls hover/complete; `terraform fmt`.
- [ ] **Helm** — chart `.tpl`/`values.yaml`: helm-ls attaches.
- [ ] **Vue** — `.vue`: LSP hover/gd/complete in `<template>` + `<script setup>`.
- [ ] **Svelte** — `.svelte`: LSP hover/gd/complete.
- [ ] **Bash** — `.sh`: `:LspInfo` → bashls; `:w` runs shfmt; shellcheck warnings show.
- [ ] **Go** — confirm golangci-lint reports (binary on PATH).
- [ ] **REGRESSION GUARD — React/TS** — `.tsx`: hover (`K`/`<leader>k`), `gd` (skips node_modules), completion, format-on-save all still correct and snappy.
- [ ] Startup still ~40ms; no new per-keystroke cost.

---

## Scope discipline (the freeze guardrail)

- **Do NOT** enable extras for languages you don't write yet (Angular and C, for now).
  Each adds Mason tools + lspconfig surface. Your own rule: *don't enable extras for
  languages not actually used.*
- **Do NOT** re-open `lsp.lua` / `blink-cmp.lua` for "while I'm in here" tweaks — those are
  the protected, load-bearing files.
- After this batch, **re-freeze and stop.** The value of the config is the months you
  *don't* touch it. New "nice to haves" → a new file in `todos/`, batched, not inline.

---

### One-line summary

> Core stack (Node fullstack + Go + Python + React/RN/Electron) = **done** (validated on the
> current prod project). **Current focus = DevOps + Go.** Go is already feature-complete —
> only `golangci-lint` needs to be on PATH. So the actionable batch is **DevOps extras
> (yaml-schema/docker/terraform/helm) + `brew install golangci-lint`**. Bash format = LOW;
> Vue/Svelte/Angular + Rust/C/C++/Ruby = deferred until actually used. One unlock session,
> then re-lock for good.
