local M = {}

-- TODO(smooth-scroll): Experimental and currently disabled.
--
-- Current state:
-- - Goal: make Ghostty/terminal mouse scrolling feel closer to VS Code by
--   spacing discrete scroll-wheel input across small timer frames.
-- - Result: transition felt smoother in some buffers, but mouse scrolling
--   paused/stuttered in heavier TSX buffers, especially while scrolling
--   continuously.
-- - Active config: lua/config/keymaps.lua intentionally uses direct native
--   <ScrollWheel*> -> <C-e>/<C-y> mappings for predictable performance.
-- - To re-test later: call `require("config.smooth-scroll").setup()` from
--   keymaps.lua, then profile redraw/render cost in the problematic TSX buffer
--   before keeping it enabled.

function M.setup(opts)
  opts = opts or {}

  local scroll_depth = opts.scroll_depth or 3
  local scroll_frame_ms = opts.scroll_frame_ms or 16
  local scroll_queue_cap = opts.scroll_queue_cap or 18
  local scroll_pending = 0
  local scroll_timer

  local function stop_smooth_scroll()
    if scroll_timer then
      scroll_timer:stop()
      scroll_timer:close()
      scroll_timer = nil
    end
  end

  local function scroll_viewport(direction)
    local mode = vim.api.nvim_get_mode().mode
    if not (mode:sub(1, 1) == "i" or mode == "n" or mode == "no") then
      return false
    end

    local view = vim.fn.winsaveview()
    view.topline = math.max(1, view.topline + direction)
    return pcall(vim.fn.winrestview, view)
  end

  local function smooth_scroll(delta)
    if delta == 0 then
      return
    end

    scroll_pending = math.min(scroll_queue_cap, math.max(-scroll_queue_cap, scroll_pending + delta))
    if scroll_timer then
      return
    end

    local uv = vim.uv or vim.loop
    scroll_timer = uv.new_timer()
    if not scroll_timer then
      local direction = delta > 0 and 1 or -1
      for _ = 1, math.abs(delta) do
        scroll_viewport(direction)
      end
      scroll_pending = 0
      return
    end

    scroll_timer:start(0, scroll_frame_ms, vim.schedule_wrap(function()
      if scroll_pending == 0 then
        stop_smooth_scroll()
        return
      end

      local direction = scroll_pending > 0 and 1 or -1
      scroll_pending = scroll_pending - direction
      if not scroll_viewport(direction) then
        scroll_pending = 0
        stop_smooth_scroll()
      end
    end))
  end

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("smooth_scroll_anim", { clear = true }),
    callback = stop_smooth_scroll,
  })

  vim.keymap.set("n", "<ScrollWheelDown>", function()
    smooth_scroll(scroll_depth)
  end, { desc = "Smooth Scroll Down" })
  vim.keymap.set("n", "<ScrollWheelUp>", function()
    smooth_scroll(-scroll_depth)
  end, { desc = "Smooth Scroll Up" })
  vim.keymap.set("i", "<ScrollWheelDown>", function()
    smooth_scroll(scroll_depth)
  end, { desc = "Smooth Scroll Down" })
  vim.keymap.set("i", "<ScrollWheelUp>", function()
    smooth_scroll(-scroll_depth)
  end, { desc = "Smooth Scroll Up" })

  return {
    smooth_scroll = smooth_scroll,
    stop = stop_smooth_scroll,
  }
end

return M
