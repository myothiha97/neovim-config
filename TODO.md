# TODO 

## AI integration updates
Feature -  custom popup for ai agents 
Feature - async ai agents completions without blocking the UI
~~fix - the current avante.nvim ai chat feature is not working well when using co pilot as provider~~
~~its taking too much time to complete the task - which is not even complex~~
✅ Fixed: switched to Claude (claude-sonnet-4) as provider with proper model ID, timeout, and max_tokens

## LSP autocompletion 
fix - currently lsp display snippets at first , this can be convenience for some cases but sometime it can be annoying when you want to see the completions list of lsp suggestions.  so we need to enhance the blink cmp a little bit

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
