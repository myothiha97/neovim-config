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

-- ── Trouble outline: scroll the code, don't highlight it ───────────────────
-- When you move (or navigate the symbols panel), Trouble previews the symbol in
-- the code window: it scrolls there (wanted) AND paints the range with the
-- `TroublePreview` group (unwanted cue). Clearing that group removes the paint
-- while keeping the auto-scroll. Re-applied on every ColorScheme so it survives
-- theme switches; Trouble links its own groups with `default = true`, so this
-- user-set (non-default) definition always wins.
local function clear_trouble_preview_hl()
  pcall(vim.api.nvim_set_hl, 0, "TroublePreview", {})
end
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("trouble_no_code_highlight", { clear = true }),
  callback = clear_trouble_preview_hl,
})
clear_trouble_preview_hl()

require("config.mouse-hover").setup()
