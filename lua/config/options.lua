-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.o.number = true
vim.o.scrolloff = 10
vim.g.material_style = "deep ocean"
vim.opt.list = false

-- Ghostty terminal optimizations
local is_ghostty = vim.env.TERM_PROGRAM == "ghostty" or vim.env.GHOSTTY_RESOURCES_DIR ~= nil

if is_ghostty then
  -- Enable 24-bit true colors (Ghostty fully supports this)
  vim.opt.termguicolors = true

  -- Undercurl support - Ghostty renders these beautifully
  vim.cmd([[let &t_Cs = "\e[4:3m"]]) -- undercurl
  vim.cmd([[let &t_Ce = "\e[4:0m"]]) -- undercurl end
  vim.cmd([[let &t_AU = "\e[58:5:%dm"]]) -- underline color (256)
  vim.cmd([[let &t_8u = "\e[58:2:%lu:%lu:%lum"]]) -- underline color (true color)

  -- Cursor shape changes (Ghostty handles these correctly)
  vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"

  -- Synchronized output (prevents tearing during redraws)
  -- Ghostty supports this via kitty protocol
  vim.opt.termsync = true
end

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

-- Ghostty supports OSC 52 for clipboard - faster than pbcopy/pbpaste
-- Falls back to pbcopy/pbpaste for non-Ghostty terminals
-- if is_ghostty then
--   vim.g.clipboard = {
--     name = "OSC 52",
--     copy = {
--       ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
--       ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
--     },
--     paste = {
--       ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
--       ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
--     },
--   }
-- else
--   vim.g.clipboard = {
--     name = "macOS-clipboard",
--     copy = {
--       ["+"] = "pbcopy",
--       ["*"] = "pbcopy",
--     },
--     paste = {
--       ["+"] = "pbpaste",
--       ["*"] = "pbpaste",
--     },
--     cache_enabled = 1,
--   }
-- end

vim.g.matchparen_timeout = 20
vim.g.matchparen_insert_timeout = 20

-- Performance optimizations
vim.opt.updatetime = 200 -- faster CursorHold (default 4000ms)
vim.opt.timeoutlen = 300 -- faster keymap timeout (default 1000ms)
vim.opt.signcolumn = "yes" -- fixed signcolumn prevents layout shift
-- vim.opt.lazyredraw = true -- DISABLED: causes async UI freezes with LSP
vim.opt.synmaxcol = 300 -- don't syntax highlight super long lines

-- Disable unused providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
