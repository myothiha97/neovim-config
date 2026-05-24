-- ── Large file guard ──────────────────────────────────────────────────────
-- Stops treesitter highlighting for files above the threshold.
-- The parser stays alive so text objects (af/if/ac/ic etc.) still work.
-- Tune LARGE_FILE_BYTES down if you still feel lag on smaller files.
local LARGE_FILE_BYTES = 100 * 1024 -- 100 KB

vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("large_file", { clear = true }),
  callback = function(args)
    local size = vim.fn.getfsize(args.match)
    if size > LARGE_FILE_BYTES then
      pcall(vim.treesitter.stop, args.buf)
    end
  end,
})

require("config.mouse-hover").setup()
