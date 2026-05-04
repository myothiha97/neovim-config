# TODO List 

## AI integration updates
Feature -  custom popup for ai agents 
Feature - async ai agents completions without blocking the UI
~~fix - the current avante.nvim ai chat feature is not working well when using co pilot as provider~~
~~its taking too much time to complete the task - which is not even complex~~
✅ Fixed: switched to Claude (claude-sonnet-4) as provider with proper model ID, timeout, and max_tokens

## Disable blink.cmp completions inside comments (TS/TSX)
✅ Resolved: due to performance bottleneck, we disabled the comments check  functions
- blink.cmp `enabled` function with `vim.treesitter.get_captures_at_pos` is not suppressing completions in comments for TypeScript/TSX files
- Treesitter comment detection works for some filetypes but not TS/TSX — likely because vtsls injects grammars or the capture name differs (`comment` vs `comment.line`, etc.)
- Needs investigation: check actual capture names via `:lua print(vim.inspect(vim.treesitter.get_captures_at_pos(0, vim.fn.line('.')-1, vim.fn.col('.')-1)))`
- Alternative approaches to explore: blink.cmp `sources` per-filetype override, or checking `vim.bo.commentstring` against current line content

## LSP autocompletion
~~fix - currently lsp display snippets at first , this can be convenience for some cases but sometime it can be annoying when you want to see the completions list of lsp suggestions.  so we need to enhance the blink cmp a little bit~~
✅ Fixed: added `fuzzy.sorts = { "exact", "score", "sort_text" }` and disabled default snippet penalty via `sources.transform_items`. Exact prefix matches now surface first (VSCode-like behavior).


## ✅ To show save/unsave status in the status line for current file and also the custom pop-up menu for all the unsaved files
✅ Fixed: bright red "● unsaved" in lualine_b; `<leader>bu` opens unsaved files popup with jump/save/save-all actions.


## ✅ Copilot lua issues (RESOLVED 2026-05-04)

**Symptom:** ghost text never appeared on TS/TSX buffers; intermittent dropouts in
prior sessions. `:Copilot status` showed `Online` + `Buffer status: attach not yet
requested`. Statusline showed `? Copilot` (status unknown).

**Root cause: TWO independent bugs masquerading as one.**

1. **nvim 0.12.0 changetracking bug** — assertion in `_changetracking.lua:299`
   ("changetracking.init must have been called for all LSP clients") fired when
   multiple LSP clients (vtsls + copilot + emmet) attached to one buffer. The
   unhandled error escaped through `send_changes` and tore down copilot's LSP
   client mid-edit. Caused the *intermittent* dropouts the TODO was tracking.
   Confirmed via diff of `runtime/lua/vim/lsp/_changetracking.lua` between
   v0.12.0 and v0.12.2 (+53/−9, new `_send_did_save` "Sends didOpen/didClose/
   didSave to all client groups", commit `fe09c71c` / fix #37454).

2. **mason-lspconfig auto-enabled the binary `copilot-language-server`** —
   leftover Mason install (probably from a past `copilot-native` extra) was
   auto-enabled by LazyVim's lspconfig setup at
   `lazyvim/plugins/lsp/init.lua:271-275`
   (`mason-lspconfig.setup({ automatic_enable = { exclude = mason_exclude } })`).
   Servers only land in `mason_exclude` if listed in `opts.servers` with
   `enabled = false` — `copilot` wasn't there, so it was auto-enabled via
   `vim.lsp.enable("copilot")`, which started nvim-lspconfig's stock
   `lsp/copilot.lua` (the binary). When `zbirenbaum/copilot.lua` plugin loaded
   on InsertEnter, both fought for the `name = "copilot"` client slot.
   nvim-lspconfig kept winning (since `vim.lsp.enable` re-attaches), so the
   plugin's per-buffer state (extmark namespace, `set_keymap`) never
   initialized. Caused the *always-broken* ghost text — the user-visible
   symptom that hid behind the TODO's intermittent-bug framing.

**Fixes applied:**

- `brew unpin neovim && brew upgrade neovim` → 0.12.0 → 0.12.2 (resolved bug #1).
  The Homebrew pin was silently keeping nvim stuck on 0.12.0 across upgrades.
- `lua/plugins/lsp.lua`: added `copilot = { enabled = false }` to the servers
  table so mason-lspconfig's `automatic_enable` excludes it. Now only the
  `zbirenbaum/copilot.lua` plugin manages copilot — no client-slot fight
  (resolved bug #2).
- `lua/plugins/performance.lua`: removed invalid `show_delay_ms = 0` field
  from `completion.trigger`. The field never existed on `trigger` in
  blink.cmp 1.10.2 (only `auto_show_delay_ms` on `completion.menu` /
  `documentation`). blink's strict validator was rejecting the field and
  short-circuiting setup, which prevented the BlinkCmp* events copilot.lua
  coordinated with.

**Workarounds removed (no longer needed):**

- `lua/plugins/lsp.lua`: dropped the `pcall`-wrap of
  `vim.lsp._changetracking.send_changes` (added to swallow the 0.12.0 assertion
  — now fixed upstream in 0.12.2).
- `lua/plugins/copilot.lua`: dropped the LspDetach auto-restart loop with
  3-per-60s rate limiting (added to self-heal when the client died — client no
  longer dies). Reverted LspDetach handler to a simple disconnect notification.
- `lua/plugins/copilot.lua`: dropped the `<C-g>` manual trigger keymap (added
  as a fallback when auto-trigger missed — auto-trigger now reliable).

**Verification:** `:checkhealth vim.lsp` now shows copilot running NodeJS
`language-server.js` from the plugin (not the Mason binary), `Buffer status:
attached`, statusline shows plain `Copilot`, ghost text renders on auto-trigger.

**Notes for future:**

- Mason still has `copilot-language-server` installed but no longer auto-enabled.
  Remove with `:MasonUninstall copilot-language-server` if desired (not required).
- `lua/plugins/copilot.lua` comments mention Blink coexistence via `BlinkCmp*`
  autocmds, but those autocmds are currently commented out. Functionally this is
  fine if Copilot/Blink overlap is not happening, but the comment should be
  cleaned up if this area is touched again.
- If anything else is later introduced that calls `vim.lsp.enable("copilot")`
  directly (e.g. re-enabling `sidekick.nvim`'s `init` block at
  `lua/plugins/sidekick.lua:21`), expect the same client-slot fight to return.
  The `enabled = false` in `lsp.lua` only blocks LazyVim's auto-enable path,
  not arbitrary direct calls.

### NES (Next Edit Suggestions) — still deferred

Only ghost-highlight is stable, NES disabled. Future goal: combine
ghost-highlight + NES into a Cursor-tab style UX. Path forward is re-enabling
`folke/sidekick.nvim` (already in `lua/plugins/sidekick.lua`, `enabled = false`).
Past attempt failed because sidekick's copilot LSP client and copilot.lua's
suggestion module fought for the same client slot — same root-cause shape as
fix #2 above. Re-enabling sidekick will require disabling copilot.lua's plugin
or carefully sequencing which one owns the client.


## Advance refactoring for large codebases
currently if the codebase is too large, i found difficult to refactor some parts of the codebase, like extracting some code to a separate file
so we need to enhance the refactoring process by adding some features like :
- extract code to a separate file and update the imports accordingly
- rename variables and functions across the codebase
- automatic generating getter and setter for classes
- automatic generating documentation for functions and classes
- automatic generating tests for functions and classes
- code coverage analysis and reporting 


## Refactoring for current Neovim configs
- currently, the lua configuration is a bit messy and hard to maintain, so we need to refactor it to make it more organized and maintainable,
by splitting it into multiple files and folders.
- might need to simplify some configurations by removing some unnecessary plugins and configurations that are not being used or not providing much value.
- need to re-analyze the current plugins and prune the unnecessary ones and only leaves the most essential ones

## ✅ Complete Avante AI agents integrations (RESOLVED 2026-05-04)

Re-enabled avante.nvim in agentic mode with Cursor-style diff acceptance keymaps.

**Key fixes:**
- Removed `providers.copilot = { model = "..." }` — this causes `model_not_supported`; model is persisted to `~/.local/state/nvim/avante/config.json` by avante, set once with `:AvanteModels`
- Added `behaviour.auto_set_keymaps = false` so manually-defined keymaps take full effect
- Added `cmd` list for lazy-loading

**Performance note:**
- `lua/plugins/avante.lua` still has `event = "VeryLazy"`, so Avante loads on `VeryLazy` even though a `cmd = { ... }` list exists. Current performance is fine, but if startup/runtime cost becomes a concern later, remove `event = "VeryLazy"` to make Avante truly command-lazy.

**Keymaps:**
- `<leader>aa` — AvanteAsk (also works in visual mode)
- `<leader>ac` — AvanteChat
- `<leader>ae` — AvanteEdit (visual selection)
- `<leader>at` — AvanteToggle (sidebar)
- `<leader>ar` — AvanteRefresh / `<leader>as` — Stop / `<leader>am` — Models
- In diff view: `A` apply all, `a` apply at cursor, `co`/`ct` ours/theirs, `]x`/`[x` navigate

**First-run required:** `:AvanteModels` → select a model (e.g. `claude-sonnet-4-5`).

## ✅ Folding — toggle all function folds (RESOLVED 2026-05-04)

`zv` — toggle fold/unfold all functions in the current file.

Uses treesitter to locate function nodes (ts/tsx/js/jsx/lua/python/go/rust). Falls back to top-level folds for other languages. Toggle: any function open → close all; all closed → open all. Cursor restored after. Added to nvim-ufo keys in `lua/plugins/folding.lua`.

## Blink cmp bugs 
- sometime in the middle of coding, using ENTER key to accept suggestions suddenly not working, instead it goes underline or next line, the issue have been persisting for a long time, so far not yet completely fix

## Prune or remove unnecessary plugins 
- currently there are still too many plugins install in the system, which dose not have a lot of use
- the target plugins quantity -> around 15-20 ( currently is 31  )  

## Performance optimization for big projects 
- Currently there are still some bottle neck with nvim runtime performance and sometime UI is lagging when scrolling in a huge files.
