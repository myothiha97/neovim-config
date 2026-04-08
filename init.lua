-- Neovide must be configured before lazy loads
if vim.g.neovide then
  vim.o.guifont = "Maple Mono NF:h14"
  vim.g.neovide_cursor_vfx_mode = ""
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_cursor_trail_size = 0
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
