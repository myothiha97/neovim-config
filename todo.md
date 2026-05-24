# ISSUES / TODOs

## Blink cmp bugs 
- sometime in the middle of coding, using ENTER key to accept suggestions suddenly not working, instead it goes underline or next line, the issue have been persisting for a long time, so far not yet completely fix


## Paste without losing the current clipboard content (override default p behavior)
 
- vim.keymap.set("n", "<leader>p", ':let @/=@"<CR>"_dP', { silent = true })


## ✅ Prune or remove unnecessary plugins 
- currently there are still too many plugins install in the system, which dose not have a lot of use
- the target plugins quantity -> around 15-20 ( currently is 31  )  

## ✅ Performance optimization for big projects 
- Currently there are still some bottle neck with nvim runtime performance and sometime UI is lagging when scrolling in a huge files.

## ✅ Bufferline.nvim "pinned-only" tabline — deferred (2026-05-06)

## ✅ Lualine.nvim: To display only file name instead of the whole path in the status line — done

## ✅ Solarized-osaka: refine solarized-osaka highlight color for grug far nvim search highlights, currently the color is too blend with the background and make it hard to see the search results

## ✅ Advance code folding features like folding imports blocks at initially when open the files initially, currently need to manually toggle with za keys , which is quite repetitive

## Solarized-osaka (Low priority): refine background color to be the solid color instead of transparent ones to improve the readability and reduce the eye strain, 

## Avante
- currently avante is completely working with both copilot and codex as providers , but the still there are some optimization left to do, especially for the UI part, currently the ui config is still pretty basic, in future might need to enhance UI for better UX 

## Nvim-scrolling
- currently i have tried my very best to make the scrolling as smooth as possible including for mouse , trackpad and keyboard navigation , but still the scrolling is not as smooth as in other ide or gui editor like web storm or zed or vscode.
So in future might need to enhance the scrolling experience by doing some research and try to find out the best way to make the scrolling experience as smooth as possible, and also need to consider about the performance when implementing the scrolling features without causing any lag or performance issue for large files or projects 
