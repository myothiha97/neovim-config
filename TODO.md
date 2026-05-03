# TODO List 

## AI integration updates
Feature -  custom popup for ai agents 
Feature - async ai agents completions without blocking the UI
~~fix - the current avante.nvim ai chat feature is not working well when using co pilot as provider~~
~~its taking too much time to complete the task - which is not even complex~~
✅ Fixed: switched to Claude (claude-sonnet-4) as provider with proper model ID, timeout, and max_tokens

## Disable blink.cmp completions inside comments (TS/TSX)
- blink.cmp `enabled` function with `vim.treesitter.get_captures_at_pos` is not suppressing completions in comments for TypeScript/TSX files
- Treesitter comment detection works for some filetypes but not TS/TSX — likely because vtsls injects grammars or the capture name differs (`comment` vs `comment.line`, etc.)
- Needs investigation: check actual capture names via `:lua print(vim.inspect(vim.treesitter.get_captures_at_pos(0, vim.fn.line('.')-1, vim.fn.col('.')-1)))`
- Alternative approaches to explore: blink.cmp `sources` per-filetype override, or checking `vim.bo.commentstring` against current line content

## LSP autocompletion
~~fix - currently lsp display snippets at first , this can be convenience for some cases but sometime it can be annoying when you want to see the completions list of lsp suggestions.  so we need to enhance the blink cmp a little bit~~
✅ Fixed: added `fuzzy.sorts = { "exact", "score", "sort_text" }` and disabled default snippet penalty via `sources.transform_items`. Exact prefix matches now surface first (VSCode-like behavior).

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


## ✅ To show save/unsave status in the status line for current file and also the custom pop-up menu for all the unsaved files
✅ Fixed: bright red "● unsaved" in lualine_b; `<leader>bu` opens unsaved files popup with jump/save/save-all actions.


## Complete Avante AI agents integrations
- currently, the avante.nvim ai agents features are barely workings and we need to complete the integration to be like a cursor ai agents that show the generated codes with a diff view and accepting the suggestions with keymaps

## Copilot lua issues 
- sometime the suggestions not appearing  after typing sometime, this issues is randomly occuring 
- currently, only ghost-highlight feature is working well , and NES features is not yet fully stable. 
- In future combine both ghost-highlight and NES to be a cursor tab like feature in cursor ide or zed editor, instead of being individual 

## Blink cmp bugs 
- sometime in the middle of coding, using ENTER key to accept suggestions suddenly not working, instead it goes underline or next line, the issue have been persisting for a long time, so far not yet completely fix

## Prune or remove unnecessary plugins 
- currently there are still too many plugins install in the system, which dose not have a lot of use
- the target plugins quantity -> around 15-20 ( currently is 31  )  

## Performance optimization for big projects 
- Currently there are still some bottle neck with nvim runtime performance and sometime UI is lagging when scrolling in a huge files.
