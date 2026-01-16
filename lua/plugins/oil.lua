local backdrop_buf = nil
local backdrop_win = nil
local saved_winhl = {}

local function close_backdrop()
  -- Restore search highlights in background windows
  for win, hl in pairs(saved_winhl) do
    if vim.api.nvim_win_is_valid(win) then
      vim.wo[win].winhighlight = hl
    end
  end
  saved_winhl = {}

  if backdrop_win and vim.api.nvim_win_is_valid(backdrop_win) then
    vim.api.nvim_win_close(backdrop_win, true)
  end
  if backdrop_buf and vim.api.nvim_buf_is_valid(backdrop_buf) then
    vim.api.nvim_buf_delete(backdrop_buf, { force = true })
  end
  backdrop_win = nil
  backdrop_buf = nil
end

local function create_backdrop()
  backdrop_buf = vim.api.nvim_create_buf(false, true)
  backdrop_win = vim.api.nvim_open_win(backdrop_buf, false, {
    relative = "editor",
    width = vim.o.columns,
    height = vim.o.lines,
    row = 0,
    col = 0,
    style = "minimal",
    focusable = false,
    zindex = 40,
  })
  vim.api.nvim_set_hl(0, "OilBackdrop", { bg = "#000000" })
  vim.wo[backdrop_win].winhighlight = "Normal:OilBackdrop"
  vim.wo[backdrop_win].winblend = 60
end

local function hide_bg_search_highlights()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    -- Skip Oil buffer and backdrop
    if not name:match("^oil://") and win ~= backdrop_win then
      saved_winhl[win] = vim.wo[win].winhighlight
      local current = vim.wo[win].winhighlight
      local hide_search = "Search:None,IncSearch:None,CurSearch:None"
      if current ~= "" then
        vim.wo[win].winhighlight = current .. "," .. hide_search
      else
        vim.wo[win].winhighlight = hide_search
      end
    end
  end
end

local function is_oil_float_open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    local config = vim.api.nvim_win_get_config(win)
    if name:match("^oil://") and config.relative ~= "" then
      return true, win
    end
  end
  return false, nil
end

local function toggle_oil()
  local open, win = is_oil_float_open()
  if open then
    close_backdrop()
    if win then
      vim.api.nvim_win_close(win, true)
    end
  else
    create_backdrop()
    require("oil").open_float()
    hide_bg_search_highlights()
  end
end

return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>e", toggle_oil, desc = "Toggle Oil Float" },
  },
  opts = {
    view_options = { show_hidden = true },
    float = {
      max_width = 0.8,
      max_height = 0.8,
      border = "rounded",
    },
  },
  config = function(_, opts)
    require("oil").setup(opts)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "oil",
      callback = function()
        local close_oil = function()
          close_backdrop()
          require("oil").close()
        end

        vim.keymap.set("n", "q", close_oil, { buffer = true })

        vim.keymap.set("n", "<ESC>", function()
          if vim.v.hlsearch == 1 then
            vim.cmd("nohlsearch")
          else
            close_oil()
          end
        end, { buffer = true })
      end,
    })

    vim.api.nvim_create_autocmd("WinClosed", {
      callback = function()
        vim.schedule(function()
          local open = is_oil_float_open()
          if not open then
            close_backdrop()
          end
        end)
      end,
    })
  end,
}
