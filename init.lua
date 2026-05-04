-- Neovide must be configured before lazy loads
if vim.g.neovide then
  vim.o.guifont = "Maple Mono NF:h14"
  vim.g.neovide_cursor_vfx_mode = ""
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_cursor_trail_size = 0

  -- Window transparency (matches Ghostty's background-opacity = 0.93)
  -- vim.g.neovide_transparency = 0.93

  -- Enable macOS Cmd key (<D->) mappings in Neovide
  vim.g.neovide_input_use_logo = true

  -- Force fresh clipboard reads from OS (don't cache between app switches)
  vim.g.clipboard = {
    name = "macOS-clipboard",
    copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
    paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
    cache_enabled = 0,
  }

  -- Pane resize with Cmd+arrow (mirrors Ghostty behavior)
  vim.keymap.set("n", "<D-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
  vim.keymap.set("n", "<D-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
  vim.keymap.set("n", "<D-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
  vim.keymap.set("n", "<D-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

  -- Cmd+I: signature help (Ghostty sends this as <M-i>)
  vim.keymap.set({ "i", "n" }, "<D-i>", vim.lsp.buf.signature_help, { desc = "Signature Help" })

  -- Cmd+F: highlight word under cursor (Ghostty sends this as <M-f>)
  vim.keymap.set("n", "<D-f>", "*N", { desc = "Highlight word under cursor" })

  -- Cmd+/: toggle comment (Ghostty sends this as <M-/>)
  vim.keymap.set("n", "<D-/>", "<cmd>normal gcc<CR>", { desc = "Toggle comment line" })
  vim.keymap.set("v", "<D-/>", "<Esc>:normal gvgc<CR>", { desc = "Toggle comment block" })

  -- Cmd+D: multi-cursor add next occurrence (Ghostty sends this as <M-d>)
  vim.keymap.set("n", "<D-d>", "<Plug>(VM-Find-Under)", { desc = "Multi-cursor: add next" })
  vim.keymap.set("v", "<D-d>", "<Plug>(VM-Find-Subword-Under)", { desc = "Multi-cursor: add next" })

  -- Clipboard: copy/paste with system clipboard
  vim.keymap.set({ "n", "v" }, "<D-c>", '"+y', { desc = "Copy to clipboard" })
  vim.keymap.set({ "n", "v" }, "<D-y>", '"+y', { desc = "Copy to clipboard" })
  vim.keymap.set("n", "<D-v>", '"+p', { desc = "Paste from clipboard" })
  vim.keymap.set("v", "<D-v>", '"+p', { desc = "Paste from clipboard" })
  vim.keymap.set("i", "<D-v>", "<C-r>+", { desc = "Paste from clipboard" })
end

-- Disable built-in matchparen — fires Highlight_Matching_Pair() on every
-- CursorMoved (1200+ calls/session). Must be set before lazy loads.
vim.g.loaded_matchparen = 1

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
