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
