local function current_line_flash(opts)
  local line = vim.api.nvim_win_get_cursor(0)[1]
  require("flash").jump(vim.tbl_deep_extend("force", {
    search = {
      multi_window = false,
      mode = function(pattern)
        return ("\\%%%dl\\V%s"):format(line, pattern:gsub("\\", "\\\\"))
      end,
    },
    label = { style = "inline" },
    highlight = { backdrop = false },
  }, opts or {}))
end

local function visual_current_line_flash()
  local visual_mode = vim.fn.mode(true):sub(1, 1)
  local visual_key = visual_mode == "V" and "V"
    or visual_mode == "\22" and vim.api.nvim_replace_termcodes("<C-v>", true, false, true)
    or "v"
  local anchor = vim.fn.getpos("v")
  local anchor_pos = { anchor[2], math.max(anchor[3] - 1, 0) }

  current_line_flash({
    action = function(match, state)
      local jump = require("flash.jump")
      jump.fix_selection()
      vim.api.nvim_set_current_win(match.win)

      if not vim.fn.mode(true):find("[vV\22]") then
        vim.api.nvim_win_set_cursor(match.win, anchor_pos)
        vim.cmd("normal! " .. visual_key)
      end

      vim.api.nvim_win_set_cursor(match.win, match.pos)
      jump.on_jump(state)
    end,
  })
end

return {
  "folke/flash.nvim",
  enabled = false,
  event = "VeryLazy",
  ---@type Flash.Config

  -- TODO: Revisit quick-motion/search workflow later. Compare flash.nvim and
  -- leap.nvim for inline motions, visual-mode selection, and whether `s`
  -- should stay native or become a dedicated search/motion key.
  opts = {
    modes = {
      char = {
        enabled = true,
        multi_line = false,
      },
    },
  },
  keys = {
    {
      "s",
      mode = { "n", "o" },
      current_line_flash,
      desc = "Flash Current Line",
    },
    {
      "s",
      mode = { "x", "s" },
      visual_current_line_flash,
      desc = "Flash Current Line",
    },
    { "S", mode = { "n", "x", "o" }, false },
  },
}
