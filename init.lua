-- Neovide must be configured before lazy loads
require("config.neovide")

-- Disable built-in matchparen — fires Highlight_Matching_Pair() on every
-- CursorMoved (1200+ calls/session). Must be set before lazy loads.
vim.g.loaded_matchparen = 1

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
