local M = {}

local SOURCE = "manual_review"
local TITLE = "Manual Review"
local MAX_ITEMS = 200

local function state_file()
  local cwd = vim.uv.cwd() or vim.fn.getcwd()
  local dir = vim.fs.joinpath(vim.fn.stdpath("state"), "manual-quickfix")
  return vim.fs.joinpath(dir, vim.fn.sha256(cwd) .. ".json")
end

local function trim_to_cap(items)
  if #items <= MAX_ITEMS then
    return items
  end

  return vim.list_slice(items, #items - MAX_ITEMS + 1, #items)
end

local function is_manual_item(item)
  local user_data = item.user_data
  return type(user_data) == "table" and user_data.source == SOURCE
end

local function filename_for(item)
  if item.filename and item.filename ~= "" then
    return item.filename
  end

  local bufnr = item.bufnr
  if type(bufnr) == "number" and bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) then
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name ~= "" then
      return name
    end
  end
end

local function persistable_item(item)
  local filename = filename_for(item)
  if not filename then
    return nil
  end

  return M.saved_item(filename, item.lnum, item.col, item.text)
end

function M.saved_item(filename, lnum, col, text)
  if type(filename) ~= "string" or filename == "" then
    return nil
  end

  return {
    filename = filename,
    lnum = tonumber(lnum) or 1,
    col = tonumber(col) or 1,
    text = tostring(text or ""),
    user_data = { source = SOURCE },
  }
end

function M.item(lnum, text)
  return {
    bufnr = vim.api.nvim_get_current_buf(),
    lnum = lnum,
    col = 1,
    text = text,
    user_data = { source = SOURCE },
  }
end

local function item_key(item)
  return table.concat({ item.filename, tostring(item.lnum), tostring(item.col), item.text }, "\0")
end

local function dedupe(items)
  local seen = {}
  local result = {}

  for _, item in ipairs(items) do
    local key = item_key(item)
    if not seen[key] then
      seen[key] = true
      result[#result + 1] = item
    end
  end

  return trim_to_cap(result)
end

local function read_saved_items()
  local file = state_file()
  if vim.fn.filereadable(file) ~= 1 then
    return {}
  end

  local ok_read, lines = pcall(vim.fn.readfile, file)
  if not ok_read or #lines == 0 then
    return {}
  end

  local ok_json, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok_json or type(decoded) ~= "table" or type(decoded.items) ~= "table" then
    return {}
  end

  local items = {}
  for _, item in ipairs(trim_to_cap(decoded.items)) do
    local saved = M.saved_item(item.filename, item.lnum, item.col, item.text)
    if saved then
      items[#items + 1] = saved
    end
  end

  return items
end

function M.save()
  local ok, qflist = pcall(vim.fn.getqflist)
  if not ok then
    return
  end

  local items = {}
  for _, item in ipairs(qflist) do
    if is_manual_item(item) then
      local saved = persistable_item(item)
      if saved then
        items[#items + 1] = saved
      end
    end
  end
  items = trim_to_cap(items)

  if #items == 0 then
    return
  end

  local saved_items = read_saved_items()
  vim.list_extend(saved_items, items)
  items = dedupe(saved_items)

  local file = state_file()
  local ok_mkdir = pcall(vim.fn.mkdir, vim.fs.dirname(file), "p")
  if not ok_mkdir then
    return
  end

  local ok_json, json = pcall(vim.json.encode, { items = items })
  if not ok_json then
    return
  end

  pcall(vim.fn.writefile, { json }, file)
end

function M.restore()
  local items = read_saved_items()
  if #items > 0 then
    local ok_current, current = pcall(vim.fn.getqflist)
    if ok_current and #current > 0 then
      return
    end

    pcall(vim.fn.setqflist, {}, "r", { title = TITLE, items = items })
  end
end

function M.clear()
  pcall(vim.fn.delete, state_file())
end

return M
