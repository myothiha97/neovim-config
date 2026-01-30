# To Fix Config

## ~~LSP not showing the registered snippets in jsx and tsx files~~
**FIXED:** Consolidated snippets config into performance.lua with `score_offset = 95` and proper `search_paths`. Removed conflicting snippets.lua config.

## ~~"nvim-treesitter/nvim-treesitter-textobjects" config not working~~
**FIXED:** Reconfigured to override `nvim-treesitter-textobjects` plugin directly (not through nvim-treesitter opts). Added `select` keymaps (af/if/ac/ic/aa/ia) and kept LazyVim-style `move.keys` for navigation.

## Snippets not showing when typing full prefix between dense code
**STATUS: Open (Low Priority)**
Custom snippets (e.g., `usf` for useState) don't appear in the completion menu when typing the full prefix between function declarations or dense code blocks. Partial prefixes (`u`, `us`) work fine. This is a blink.cmp fuzzy matcher limitation — LSP results like `useState` score higher in rich code contexts and push snippets out despite `score_offset = 200`. Potential future fix: investigate blink.cmp `fuzzy.implementation` or custom `sort` functions to always boost snippet-kind items.
