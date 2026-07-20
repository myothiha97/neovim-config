-- UNSTABLE: parked until the tabline's top whitespace and visual design are
-- resolved. This module must not be required from init.lua while it is parked.
-- A deliberately small, static tabline. The rendered string is rebuilt only on
-- buffer/window/diagnostic events; Neovim redraws it without executing Lua.
-- This avoids the redraw-path cost of a `%!` tabline expression and avoids a
-- third-party tab plugin's always-on bookkeeping.
local M = {}

local state = {
  buffers = {},
  index = {},
  diagnostics = {},
  pinned = {},
  explorer_win = nil,
  explorer_open = false,
  refresh_scheduled = false,
  setup = false,
  devicons = nil,
}

local MAX_NAME_WIDTH = 24
local SPECIAL_FILETYPES = {
  ["codecompanion"] = true,
  ["grug-far"] = true,
  ["help"] = true,
  ["oil"] = true,
  ["qf"] = true,
  ["trouble"] = true,
}

local function escape(text)
  return text:gsub("%%", "%%%%")
end

local function shorten(text, width)
  if vim.fn.strdisplaywidth(text) <= width then
    return text
  end
  local ret = ""
  for _, char in ipairs(vim.fn.split(text, "\\zs")) do
    if vim.fn.strdisplaywidth(ret .. char .. "…") > width then
      break
    end
    ret = ret .. char
  end
  return ret .. "…"
end

local function is_file_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.bo[buf].buflisted or vim.bo[buf].buftype ~= "" then
    return false
  end
  if SPECIAL_FILETYPES[vim.bo[buf].filetype] or vim.bo[buf].filetype:match("^snacks_") then
    return false
  end
  return vim.api.nvim_buf_get_name(buf) ~= "" or vim.bo[buf].modified
end

local function reindex()
  state.index = {}
  for i, buf in ipairs(state.buffers) do
    state.index[buf] = i
  end
end

local function diagnostic_counts(buf)
  local counts = vim.diagnostic.count(buf)
  return {
    errors = counts[vim.diagnostic.severity.ERROR] or 0,
    warnings = counts[vim.diagnostic.severity.WARN] or 0,
  }
end

local function refresh_buffer(buf)
  local index = state.index[buf]
  if is_file_buffer(buf) then
    if not index then
      state.buffers[#state.buffers + 1] = buf
      state.index[buf] = #state.buffers
    end
    state.diagnostics[buf] = diagnostic_counts(buf)
  elseif index then
    table.remove(state.buffers, index)
    state.diagnostics[buf] = nil
    state.pinned[buf] = nil
    reindex()
  end
end

local function refresh_all_buffers()
  state.buffers = {}
  state.index = {}
  state.diagnostics = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if is_file_buffer(buf) then
      state.buffers[#state.buffers + 1] = buf
      state.diagnostics[buf] = diagnostic_counts(buf)
    end
  end
  table.sort(state.buffers)
  reindex()
end

local function file_icon(buf, name)
  if not state.devicons then
    return ""
  end
  local icon = state.devicons.get_icon(name, vim.bo[buf].filetype, { default = true })
  return icon or ""
end

local function tab_text(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  local label = name == "" and "Untitled" or vim.fn.fnamemodify(name, ":t")
  label = shorten(label, MAX_NAME_WIDTH)
  local diagnostics = state.diagnostics[buf] or { errors = 0, warnings = 0 }
  local modified = vim.bo[buf].modified and "%#ConfigTablineModified# ●" or ""
  local badges = ""
  if diagnostics.errors > 0 then
    badges = badges .. (" %%#ConfigTablineError# %d"):format(diagnostics.errors)
  end
  if diagnostics.warnings > 0 then
    badges = badges .. (" %%#ConfigTablineWarn# %d"):format(diagnostics.warnings)
  end
  local pin = state.pinned[buf] and "%#ConfigTablinePinned# 󰐃" or ""
  return (" %s %s%s%s%s "):format(file_icon(buf, name), escape(label), modified, badges, pin)
end

local function tab_width(buf)
  -- Highlight and click markers occupy no columns, so strip them before measuring.
  local plain = tab_text(buf):gsub("%%#.-#", "")
  return vim.fn.strdisplaywidth(plain) + 2 -- close button
end

local function explorer_offset()
  local win = state.explorer_win
  if not state.explorer_open or not win or not vim.api.nvim_win_is_valid(win) then
    return 0
  end
  local _, col = unpack(vim.api.nvim_win_get_position(win))
  return col == 0 and vim.api.nvim_win_get_width(win) or 0
end

local function visible_range(offset)
  local current = vim.api.nvim_get_current_buf()
  local current_index = state.index[current] or 1
  local available = math.max(20, vim.o.columns - offset - 4)
  local first, last = current_index, current_index
  local used = tab_width(state.buffers[current_index])

  while last < #state.buffers and used + tab_width(state.buffers[last + 1]) <= available do
    last = last + 1
    used = used + tab_width(state.buffers[last])
  end
  while first > 1 and used + tab_width(state.buffers[first - 1]) <= available do
    first = first - 1
    used = used + tab_width(state.buffers[first])
  end
  return first, last
end

local function clickable(buf, handler, text)
  return ("%%%d@%s@%s%%T"):format(buf, handler, text)
end

function M.render()
  local offset = explorer_offset()
  local parts = { "%#ConfigTablineFill#" }
  if offset > 0 then
    parts[#parts + 1] = "%#ConfigTablineExplorerOffset#" .. string.rep(" ", offset)
  end

  if #state.buffers == 0 then
    parts[#parts + 1] = "%#ConfigTablineFill#%="
    vim.o.tabline = table.concat(parts)
    return
  end

  local first, last = visible_range(offset)
  if first > 1 then
    parts[#parts + 1] = "%#ConfigTablineFill# ‹ "
  end

  local current = vim.api.nvim_get_current_buf()
  for i = first, last do
    local buf = state.buffers[i]
    local highlight = buf == current and "ConfigTablineActive" or "ConfigTablineInactive"
    parts[#parts + 1] = "%#" .. highlight .. "#"
    parts[#parts + 1] = clickable(buf, "ConfigTablineGoto", tab_text(buf))
    parts[#parts + 1] = "%#" .. highlight .. "#"
    parts[#parts + 1] = clickable(buf, "ConfigTablineClose", " × ")
  end

  if last < #state.buffers then
    parts[#parts + 1] = "%#ConfigTablineFill# ›"
  end
  parts[#parts + 1] = "%#ConfigTablineFill#%="
  vim.o.tabline = table.concat(parts)
end

function M.refresh(buf)
  if buf then
    refresh_buffer(buf)
  end
  M.render()
end

local function schedule_offset_refresh()
  if state.refresh_scheduled then
    return
  end
  state.refresh_scheduled = true
  vim.schedule(function()
    state.refresh_scheduled = false
    M.refresh()
  end)
end

function M.set_explorer(picker)
  state.explorer_open = true
  state.explorer_win = picker and picker.list and picker.list.win and picker.list.win.win or nil
  schedule_offset_refresh()
end

function M.clear_explorer(picker)
  local win = picker and picker.list and picker.list.win and picker.list.win.win or nil
  if not win or win == state.explorer_win then
    state.explorer_open = false
    state.explorer_win = nil
    schedule_offset_refresh()
  end
end

function M.goto_buffer(buf)
  if buf and vim.api.nvim_buf_is_valid(buf) and is_file_buffer(buf) then
    vim.api.nvim_set_current_buf(buf)
  end
end

function M.close_buffer(buf)
  if vim.api.nvim_buf_is_valid(buf) then
    require("snacks").bufdelete(buf)
  end
end

local function cycle(step)
  if #state.buffers < 2 then
    return
  end
  local current = state.index[vim.api.nvim_get_current_buf()] or 1
  local target = ((current - 1 + step) % #state.buffers) + 1
  M.goto_buffer(state.buffers[target])
end

local function move_current(step)
  local current = vim.api.nvim_get_current_buf()
  local index = state.index[current]
  if not index then
    return
  end
  local target = math.max(1, math.min(#state.buffers, index + step))
  if target == index then
    return
  end
  state.buffers[index], state.buffers[target] = state.buffers[target], state.buffers[index]
  reindex()
  M.refresh()
end

local function toggle_pin()
  local buf = vim.api.nvim_get_current_buf()
  if not state.index[buf] then
    return
  end
  if state.pinned[buf] then
    state.pinned[buf] = nil
  else
    state.pinned[buf] = true
  end
  M.refresh()
end

local function delete_in_direction(step)
  local current = state.index[vim.api.nvim_get_current_buf()]
  if not current then
    return
  end
  local targets = {}
  if step < 0 then
    for i = 1, current - 1 do
      targets[state.buffers[i]] = true
    end
  else
    for i = current + 1, #state.buffers do
      targets[state.buffers[i]] = true
    end
  end
  require("snacks").bufdelete({ filter = function(buf) return targets[buf] end })
end

local function delete_non_pinned()
  require("snacks").bufdelete({
    filter = function(buf)
      return state.index[buf] ~= nil and not state.pinned[buf]
    end,
  })
end

local function pick_buffer()
  vim.ui.select(state.buffers, {
    prompt = "Pick buffer",
    format_item = function(buf)
      local name = vim.api.nvim_buf_get_name(buf)
      return name == "" and "Untitled" or vim.fn.fnamemodify(name, ":.")
    end,
  }, M.goto_buffer)
end

local function install_keymaps()
  local map = vim.keymap.set
  map("n", "<S-h>", function() cycle(-1) end, { desc = "Prev Buffer" })
  map("n", "<S-l>", function() cycle(1) end, { desc = "Next Buffer" })
  map("n", "[b", function() cycle(-1) end, { desc = "Prev Buffer" })
  map("n", "]b", function() cycle(1) end, { desc = "Next Buffer" })
  map("n", "[B", function() move_current(-1) end, { desc = "Move buffer prev" })
  map("n", "]B", function() move_current(1) end, { desc = "Move buffer next" })
  map("n", "<leader>bj", pick_buffer, { desc = "Pick Buffer" })
  map("n", "<leader>bp", toggle_pin, { desc = "Toggle Pin" })
  map("n", "<leader>bP", delete_non_pinned, { desc = "Delete Non-Pinned Buffers" })
  map("n", "<leader>br", function() delete_in_direction(1) end, { desc = "Delete Buffers to the Right" })
  map("n", "<leader>bl", function() delete_in_direction(-1) end, { desc = "Delete Buffers to the Left" })

  -- Keep LazyVim's core buffer behavior and descriptions.
  map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
  map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
  map("n", "<leader>bd", function() require("snacks").bufdelete() end, { desc = "Delete Buffer" })
  map("n", "<leader>bo", function() require("snacks").bufdelete.other() end, { desc = "Delete Other Buffers" })
  map("n", "<leader>bi", function() require("snacks").bufdelete.invisible() end, { desc = "Delete Invisible Buffers" })
  map("n", "<leader>bD", "<cmd>bd<cr>", { desc = "Delete Buffer and Window" })
end

local function set_highlights()
  vim.api.nvim_set_hl(0, "ConfigTablineActive", { link = "TabLineSel" })
  vim.api.nvim_set_hl(0, "ConfigTablineInactive", { link = "TabLine" })
  vim.api.nvim_set_hl(0, "ConfigTablineFill", { link = "TabLineFill" })
  vim.api.nvim_set_hl(0, "ConfigTablineExplorerOffset", { link = "Normal" })
  vim.api.nvim_set_hl(0, "ConfigTablineModified", { link = "DiagnosticWarn" })
  vim.api.nvim_set_hl(0, "ConfigTablineError", { link = "DiagnosticError" })
  vim.api.nvim_set_hl(0, "ConfigTablineWarn", { link = "DiagnosticWarn" })
  vim.api.nvim_set_hl(0, "ConfigTablinePinned", { link = "Special" })
end

function M.setup()
  if state.setup then
    return
  end
  state.setup = true
  vim.o.showtabline = 2
  set_highlights()
  local ok, devicons = pcall(require, "nvim-web-devicons")
  state.devicons = ok and devicons or nil
  refresh_all_buffers()

  _G.ConfigTablineGoto = function(minwid, _, button)
    if button == "l" then
      M.goto_buffer(minwid)
    elseif button == "m" then
      M.close_buffer(minwid)
    end
  end
  _G.ConfigTablineClose = function(minwid, _, button)
    if button == "l" or button == "m" then
      M.close_buffer(minwid)
    end
  end

  local group = vim.api.nvim_create_augroup("config_static_tabline", { clear = true })
  vim.api.nvim_create_autocmd({ "BufAdd", "BufEnter", "BufFilePost", "BufModifiedSet" }, {
    group = group,
    callback = function(args)
      M.refresh(args.buf)
    end,
  })
  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = group,
    callback = function(args)
      refresh_buffer(args.buf)
      M.render()
    end,
  })
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = group,
    callback = function(args)
      if state.index[args.buf] then
        state.diagnostics[args.buf] = diagnostic_counts(args.buf)
        M.render()
      end
    end,
  })
  vim.api.nvim_create_autocmd({ "WinEnter", "TabEnter" }, {
    group = group,
    callback = M.render,
  })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      set_highlights()
      M.render()
    end,
  })
  vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
    group = group,
    callback = schedule_offset_refresh,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    callback = install_keymaps,
  })

  M.render()
end

return M
