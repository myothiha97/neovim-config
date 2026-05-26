# ISSUES / TODOs


## ✅ Prune or remove unnecessary plugins 
- currently there are still too many plugins install in the system, which dose not have a lot of use
- the target plugins quantity -> around 15-20 ( currently is 31  )  

## ✅ Performance optimization for big projects 
- Currently there are still some bottle neck with nvim runtime performance and sometime UI is lagging when scrolling in a huge files.

## ✅ Bufferline.nvim "pinned-only" tabline — deferred (2026-05-06)

## ✅ Lualine.nvim: To display only file name instead of the whole path in the status line — done

## ✅ Solarized-osaka: refine solarized-osaka highlight color for grug far nvim search highlights, currently the color is too blend with the background and make it hard to see the search results

## ✅ Advance code folding features like folding imports blocks at initially when open the files initially, currently need to manually toggle with za keys , which is quite repetitive


## Blink cmp bugs (currently not longer happen, but still need to check and monitor the issue to make sure it is completely fixed)
- sometime in the middle of coding, using ENTER key to accept suggestions suddenly not working, instead it goes underline or next line, the issue have been persisting for a long time, so far not yet completely fix


## Paste without losing the current clipboard content (override default p behavior)
- vim.keymap.set("n", "<leader>p", ':let @/=@"<CR>"_dP', { silent = true })


## Solarized-osaka (Low priority): refine background color to be the solid color instead of transparent ones to improve the readability and reduce the eye strain, 

## Avante
- currently avante is completely working with both copilot and codex as providers , but the still there are some optimization left to do, especially for the UI part, currently the ui config is still pretty basic, in future might need to enhance UI for better UX 
- disabled markdown preview when using avante chats panel

## Nvim-scrolling
- currently i have tried my very best to make the scrolling as smooth as possible including for mouse , trackpad and keyboard navigation , but still the scrolling is not as smooth as in other ide or gui editor like web storm or zed or vscode.
So in future might need to enhance the scrolling experience by doing some research and try to find out the best way to make the scrolling experience as smooth as possible, and also need to consider about the performance when implementing the scrolling features without causing any lag or performance issue for large files or projects 

## Folding follow-up
- Review whether the initial JS/TS import auto-folding behavior should stay enabled or be removed.
- Relevant code in lua/plugins/folding.lua:
  - line 122: init = function()
  - line 127: get_first_import_line
  - line 137: Tree-sitter query for (import_statement)
  - line 179: BufReadPost autocmd for *.ts, *.tsx, *.js, *.jsx
  - line 196: calls try_fold(...), which runs normal! zc

## Config Refactoring

Refactor and simplify the current configuration files to make them more consistent, maintainable, and easier to extend for additional languages.

The main goal is to unify configs for:

* LSP
* Folding
* Search and replace
* Diagnostics
* Debugging
* Code analysis

This will help us apply and reuse similar configurations across different languages more easily.

### Target Language Priorities and Current Config State

* **TS/JS** — Fully configured
* **Go** — Not configured yet
* **Python** — Partially configured around 30%; some LSP features may already work
* **Rust** — Not configured yet
* **C** — Not configured yet

### ✅ Quick AI prompt actions — done

Implemented custom commands and `<leader>ac` keymaps that copy short, reusable prompts to the system clipboard for external AI agents like Claude or Codex.

* `<leader>acc` / `:AICopyCommitPrompt` — Copy commit-message prompt
* `<leader>aca` / `:AICopyCodebaseAnalysisPrompt` — Copy codebase-analysis prompt
* `<leader>ace` / `:AICopyExplainCurrentContextPrompt` — Copy current-file explanation prompt
* `<leader>acf` / `:AICopyRefactorPrompt` — Copy generic refactor prompt
* `<leader>acr` / `:AICopyReviewChangesPrompt` — Copy pre-commit code/architecture review prompt
* `<leader>acs` / `:AICopyExplainCurrentSymbolPrompt` — Copy current function/class/expression explanation prompt
* `<leader>acd` (visual) / `:AICopyExplainSelectionPrompt` — Copy selected code/text explanation prompt

LazyVim codelens keymaps are disabled because they are unused, keeping `<leader>c` reserved for pure code actions.

### Planned Improvements

Add custom commands or keymaps for code analysis actions, such as:

* Check code coverage or code quality and display the results in a popup or dedicated pane
* Analyze all variables, functions, classes, objects, and other symbols used in specific files, including their usage counts, and display the results in a popup or dedicated pane


## Comprehensive Debugging Setup with nvim-dap and nvim-dap-ui

Set up a complete debugging workflow in Neovim using nvim-dap and nvim-dap-ui.

__Language Priorities__

* Primary languages — JS/TS, Python, and Go
* Secondary target languages — Rust, C, C#, and Bash

## Snacks Explorer: Folder-click cursor flicker

### Issue
When clicking a folder in Snacks explorer, the cursor briefly jumps to the top of the list before returning to the clicked row. This creates a small flicker during folder expand/collapse.

### Root Cause
This appears to be an upstream Snacks issue, not our config.

Folder toggle uses:

`M.actions.confirm → Tree:toggle → M.update → picker:find()`

`picker:find()` refreshes the list asynchronously. During the brief gap between clearing and re-rendering the list, the target row does not exist yet, so the cursor temporarily renders at row 1. Once Snacks restores the target row, the final cursor position is correct.

This likely also affects keyboard `<CR>`, but mouse clicks make it more visible.

### Why we are not fixing it now
- The flicker happens inside Snacks’ async render pipeline.
- `lazyredraw` did not suppress the intermediate render.
- Deeper workarounds would require touching Snacks internals and may break on future updates.
- The issue is cosmetic and only lasts a few milliseconds, so the cost/risk is not justified.

### Possible future fixes
1. Wait for an upstream Snacks fix.
2. Test direct `actions.confirm(...)` instead of `picker:action("confirm")`.
3. Try pre-setting the cursor target before running the action.
4. Last resort: rewrite the toggle/find flow synchronously, though this is brittle and high-risk.

### Related code
`lua/plugins/snacks.lua:97`

Specifically:

```lua
if item.dir or picker.input.filter.meta.searching then
  picker:action("confirm")
end
