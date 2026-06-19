# Freeze-Day Runbook — the LAST config session before freezing 2026

> A do-it-tomorrow checklist. Self-contained — just follow top to bottom.
> Rationale/audit lives in [`production-stack-gap-closure.md`](./production-stack-gap-closure.md).
> Scope = **main stack only: Go + Node + DevOps + Python.** Everything else is deferred.
> Estimated time: **~30–45 min** (most of it Mason downloading + verifying).

---

## TL;DR of what you're doing

1. Install one binary: `golangci-lint` (Go's only gap).
2. Enable 4 DevOps LazyVim extras (yaml/docker/terraform/helm).
3. (Optional) 2-line Bash formatter wiring.
4. Run a verify sweep so you freeze a *known-good* state.
5. Re-lock + commit. Done for the year.

**Nothing here touches `lsp.lua` or `blink-cmp.lua`.** All additive + filetype-lazy.

---

## STEP 0 — Pre-flight (2 min)

- [ ] Start clean: `cd ~/.config/nvim && git status` → should be clean (commit/stash anything stray first).
- [ ] Make a safety branch so the whole batch is revertible:
  ```bash
  git switch -c freeze-prep-2026
  ```
- [ ] Note current startup baseline (to compare after):
  ```bash
  nvim --startuptime /tmp/before.log +q && tail -1 /tmp/before.log
  ```

---

## STEP 1 — Go: install the linter (2 min)

Go is already fully configured (gopls/gofumpt/goimports/delve/neotest-golang). The ONLY
missing piece is the linter binary:

- [ ] ```bash
  brew install golangci-lint
  golangci-lint --version   # confirm it's on PATH
  ```

That's all Go needs. (No nvim edit — the Go extra already wires it.)

---

## STEP 2 — DevOps: enable the 4 extras (10 min, mostly downloads)

These must run in an **unlock session** so Mason/lazy can install:

- [ ] Launch unlocked: `NVIM_LAZY_UNLOCK=1 nvim`
- [ ] `:LazyExtras` → press `x` to enable each of these (search/scroll to find them):
  - [ ] `lang.yaml`      ← **highest value**: SchemaStore → k8s / GitHub Actions / compose intellisense
  - [ ] `lang.docker`    ← Dockerfile + compose LSP, hadolint
  - [ ] `lang.terraform` ← terraform-ls
  - [ ] `lang.helm`      ← helm-ls
- [ ] Restart nvim when prompted. On restart, lazy installs the plugins and Mason
      auto-installs the servers. Watch `:Mason` until downloads finish (look for
      `terraform-ls`, `helm-ls`, `dockerfile-language-server`, `docker-compose-language-service`, `hadolint`).

> If a Mason tool fails to install: `:Mason` → find it → press `i` to retry.

---

## STEP 3 — (OPTIONAL) Bash formatter (2 min)

LSP + shellcheck already work for `.sh`; only auto-format is missing. Skip if you don't care.

- [ ] Edit `lua/plugins/formatting.lua` → inside `formatters_by_ft = { ... }` add:
  ```lua
  sh   = { "shfmt" },
  bash = { "shfmt" },
  ```
  (`shfmt` is already installed in Mason — no download.)

---

## STEP 4 — Verify sweep (10–15 min) — freeze a KNOWN-GOOD state

Open one real file of each type and confirm. Don't skip the regression guard.

**DevOps (the new stuff):**
- [ ] **YAML/k8s** — open any `*.yaml` (a k8s manifest or `.github/workflows/ci.yml`):
      typing a known key offers schema completion; bad values show a diagnostic.
- [ ] **Docker** — open a `Dockerfile`: `:LspInfo` shows dockerls; hover on an instruction works.
      Open a `docker-compose.yml`: completion appears.
- [ ] **Terraform** — open a `.tf`: `:LspInfo` shows terraform-ls; hover/complete works.
- [ ] **Helm** — open a chart `values.yaml` or `templates/*.tpl`: helm-ls attaches.

**Main stack (confirm nothing broke):**
- [ ] **Go** — open a `.go` in a real module: `gd`, `K` hover, save→goimports formats,
      and `golangci-lint` warnings now surface. `<leader>td` debug hits a breakpoint (delve).
- [ ] **Python** — open a `.py` in a venv project: `:VenvSelect` picks the interpreter;
      basedpyright hover + ruff format-on-save work; debugpy hits a breakpoint.
- [ ] **REGRESSION GUARD — React/TS** — open a real `.tsx` from a Rezeve portal:
      `K`/`<leader>k` hover, `gd` (skips node_modules), completion, format-on-save —
      all still correct **and snappy**. (Most important check — it's your daily driver.)

**Perf:**
- [ ] ```bash
  nvim --startuptime /tmp/after.log +q && tail -1 /tmp/after.log
  ```
  Compare with `/tmp/before.log` — should be within a few ms (extras are filetype-lazy).

---

## STEP 5 — Re-lock + commit (5 min)

- [ ] **Run the perf check** (project rule): in nvim `:` →  load `/perf-review` on the diff,
      or just confirm Step 4's perf compare passed.
- [ ] Quit nvim. Re-open plain (`nvim`) once — confirm the **freeze is back on**
      (try `:Lazy sync` → you should get the "frozen — blocked" notification).
- [ ] Commit everything together:
  ```bash
  git add lazy-lock.json lazyvim.json lua/plugins/formatting.lua todos/
  git commit   # message e.g.: feat(lang): enable devops stack (yaml/docker/terraform/helm) + go lint
  ```
- [ ] Merge the branch back:
  ```bash
  git switch main && git merge --ff-only freeze-prep-2026
  ```
- [ ] (If you push) `git push`.

---

## STEP 6 — Close it out

- [ ] Mark this runbook ✅ and `production-stack-gap-closure.md` done.
- [ ] Prune the now-finished DevOps/Go rows from `multi-language-support.md`.
- [ ] **Stop.** The config is frozen for 2026. New ideas → a new file in `todos/`, never inline.

---

## ⛔ Do NOT do tomorrow (scope creep traps)

- ❌ Vue / Svelte / Angular extras — not coding them this year.
- ❌ Rust / C / C++ / Ruby — 2027+. (Rust just needs `rustup` later; no nvim edit.)
- ❌ "While I'm in here" tweaks to `lsp.lua` / `blink-cmp.lua` / completion / lualine.
- ❌ Re-theming, new plugins, keymap rabbit holes.

If you feel the itch: write it in a new `todos/*.md` and walk away. That's the whole freeze discipline.

---

### If something goes wrong

- A new server misbehaves or tanks perf → just disable that one extra in `:LazyExtras` and restart.
- Whole batch feels off → `git switch main` (you never merged the branch yet) and you're back to the frozen-good config. Try again another day.
