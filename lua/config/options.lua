-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.o.number = true
vim.o.scrolloff = 10
vim.g.material_style = "deep ocean"
vim.opt.list = false

vim.diagnostic.config({
  float = {
    border = "rounded",
    max_width = 60, -- Forces the window to wrap after 60 characters
    source = "always",
    header = "",
    prefix = "",
  },
})
