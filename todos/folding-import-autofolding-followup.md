
# Folding: JS/TS Import Auto-folding Follow-up

## Decision Needed
Review whether the initial JS/TS import auto-folding behavior should stay enabled or be removed.

## Relevant Code
`lua/plugins/folding.lua`:
- Line 122: `init = function()`
- Line 127: `get_first_import_line`
- Line 137: Tree-sitter query for `(import_statement)`
- Line 179: `BufReadPost` autocmd for `*.ts`, `*.tsx`, `*.js`, `*.jsx`
- Line 196: calls `try_fold(...)`, which runs `normal! zc`

## Considerations
- Auto-folding imports on open reduces noise in large files.
- However, it may be surprising/disruptive when you open a file expecting to see the full source.
- Evaluate after daily use: does it help or get in the way more often?
