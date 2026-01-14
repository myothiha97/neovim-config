-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

local comment_key = "<leader>c"

vim.keymap.set("n", "<leader>va", "ggVG", { desc = "Select all the text in the current file" })
vim.keymap.set("n", "<leader>ya", "ggyG", { desc = "Yank all text" })

-- Normal mode: Comment the current line
vim.keymap.set("n", comment_key, "<cmd>normal gcc<CR>", { desc = "Toggle comment line" })

-- Visual mode: Comment the highlighted selection
vim.keymap.set("v", comment_key, "<Esc>:normal gvgc<CR>", { desc = "Toggle comment block" })

-- recenter the page when hit ctrl-d/u/f/b
vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz", { desc = "Scroll Down and Recenter" })
vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>zz", { desc = "Scroll Up and Recenter" })
vim.keymap.set({ "n", "v" }, "<C-f>", "<C-f>zz", { desc = "Scroll Down by entire page and Recenter" })
vim.keymap.set({ "n", "v" }, "<C-b>", "<C-b>zz", { desc = "Scroll Up by entire page and Recenter" })

-- keymaps for quick save actions
vim.keymap.set({ "n", "v", "i" }, "<leader>w", "<cmd>w<CR>", { desc = "Save current buffer" })

-- terminal mode
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true })

-- map(mode, key, result, options)
vim.keymap.set("n", "gi", function()
  vim.diagnostic.open_float({
    focusable = true, -- Allows you to tab into the window or focus it
    border = "rounded",
    source = "always", -- Shows which LSP (e.g., jdtls) sent the error
  })
end, { desc = "Line Diagnostics (Focusable)" })

-- Configuration to only target Errors
local error_only_config = {
  severity = vim.diagnostic.severity.ERROR,
  float = { border = "rounded", source = "always" },
}

-- Go to next ERROR
vim.keymap.set("n", "ge", function()
  vim.diagnostic.jump({
    count = 1,
    severity = error_only_config.severity,
    float = error_only_config.float,
  })
end, { desc = "Next Error" })

-- Go to previous ERROR
vim.keymap.set("n", "gp", function()
  vim.diagnostic.jump({
    count = -1,
    severity = error_only_config.severity,
    float = error_only_config.float,
  })
end, { desc = "Prev Error" })
