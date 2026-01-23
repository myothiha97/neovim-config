-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.o.number = true
vim.o.scrolloff = 10
vim.g.material_style = "deep ocean"
vim.opt.list = false

-- Create gap at top by adding empty winbar (pushes content down)
vim.opt.winbar = " " -- Single space creates 1 line of padding
-- vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE", sp = "NONE" })
-- vim.api.nvim_set_hl(0, "WinBarNC", { bg = "NONE", sp = "NONE" })

vim.diagnostic.config({
  float = {
    border = "rounded",
    max_width = 60, -- Forces the window to wrap after 60 characters
    source = "always",
    header = "",
    prefix = "",
  },
})

vim.opt.clipboard = "unnamedplus"

-- Or use this for async clipboard (less laggy)
vim.g.clipboard = {
  name = "macOS-clipboard",
  copy = {
    ["+"] = "pbcopy",
    ["*"] = "pbcopy",
  },
  paste = {
    ["+"] = "pbpaste",
    ["*"] = "pbpaste",
  },
  cache_enabled = 1,
}

vim.g.matchparen_timeout = 20
vim.g.matchparen_insert_timeout = 20
