local M = {}

local persistence = require("config.quickfix-persistence")

local function quickfix_winid_for(bufnr)
  for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
    if vim.fn.getwinvar(win, "&buftype") == "quickfix" then
      return win
    end
  end
end

local function quickfix_items_for(winid)
  local info = vim.fn.getwininfo(winid)[1]
  if not info then
    return
  end

  if info.loclist == 1 then
    return vim.fn.getloclist(info.winnr)
  end

  return vim.fn.getqflist()
end

local function remove_entries(bufnr, start_lnum, end_lnum)
  local winid = quickfix_winid_for(bufnr)
  if not winid then
    return
  end

  local info = vim.fn.getwininfo(winid)[1]
  local items = quickfix_items_for(winid)
  if not info or type(items) ~= "table" or #items == 0 then
    return
  end

  local first = math.max(1, math.min(start_lnum, end_lnum))
  local last = math.min(#items, math.max(start_lnum, end_lnum))
  if first > last then
    return
  end

  local targets = vim.list_slice(items, first, last)
  if info.loclist == 1 then
    local kept = {}
    for idx, item in ipairs(items) do
      if idx < first or idx > last then
        kept[#kept + 1] = item
      end
    end
    local title = vim.fn.getloclist(info.winnr, { title = 0 }).title
    pcall(vim.fn.setloclist, info.winnr, {}, "r", { title = title, items = kept })
    if #kept == 0 then
      vim.cmd.lclose()
      return
    end
    pcall(vim.api.nvim_win_set_cursor, winid, { math.min(first, #kept), 0 })
    return
  end

  persistence.remove(targets)

  local remaining = vim.fn.getqflist()
  if #remaining == 0 then
    vim.cmd.cclose()
    return
  end

  pcall(vim.api.nvim_win_set_cursor, winid, { math.min(first, #remaining), 0 })
end

function M.setup_buffer(bufnr)
  local opts = { buffer = bufnr, silent = true, nowait = true }

  vim.keymap.set("n", "dd", function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    remove_entries(bufnr, line, line)
  end, vim.tbl_extend("force", opts, { desc = "Remove quickfix entry" }))

  vim.keymap.set("x", "d", function()
    local start_lnum = vim.fn.line("v")
    local end_lnum = vim.fn.line(".")
    remove_entries(bufnr, start_lnum, end_lnum)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  end, vim.tbl_extend("force", opts, { desc = "Remove quickfix entries" }))

  vim.keymap.set("n", "x", function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    remove_entries(bufnr, line, line)
  end, vim.tbl_extend("force", opts, { desc = "Remove quickfix entry" }))
end

return M
