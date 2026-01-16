local backdrop_buf = nil
local backdrop_win = nil

local function close_backdrop()
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
        vim.keymap.set("n", "q", function()
          close_backdrop()
          require("oil").close()
        end, { buffer = true })

        vim.keymap.set("n", "<ESC>", function()
          close_backdrop()
          require("oil").close()
        end, { buffer = true })
      end,
    })

    -- Fallback cleanup when Oil window closes
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
