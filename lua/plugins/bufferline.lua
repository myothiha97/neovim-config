-- bufferline.nvim configured as a "pinned-only" favorites bar.
-- Default behavior of bufferline shows every visited buffer; we override that
-- via custom_filter so only buffers the user explicitly pins appear. Pin set
-- is path-keyed so it survives :bd + reopen within a session (not persisted
-- across nvim restarts).
return {
  {
    "akinsho/bufferline.nvim",
    enabled = false,
    lazy = false,
    priority = 900, -- after colorscheme (which is usually 1000)
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Force the tabline slot to always be reserved, even before bufferline
      -- finishes setup. Otherwise a failed setup leaves no top line at all.
      vim.opt.showtabline = 2

      local pinned = {}

      local function current_path()
        return vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
      end

      -- Soft threshold: above this we nudge the user that they're accumulating
      -- tabs. Not a hard cap — pinning still succeeds, just with a warning.
      local soft_limit = 5

      local function count_pinned()
        local n = 0
        for _ in pairs(pinned) do
          n = n + 1
        end
        return n
      end

      local function toggle_pin()
        local path = current_path()
        if path == "" then
          vim.notify("Cannot pin unnamed buffer", vim.log.levels.WARN, { title = "Bufferline" })
          return
        end
        if pinned[path] then
          pinned[path] = nil
          vim.notify("Unpinned: " .. vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO, { title = "Bufferline" })
        else
          pinned[path] = true
          local n = count_pinned()
          local name = vim.fn.fnamemodify(path, ":t")
          if n > soft_limit then
            vim.notify(
              ("Pinned: %s  (%d pinned — getting busy, consider unpinning)"):format(name, n),
              vim.log.levels.WARN,
              { title = "Bufferline" }
            )
          else
            vim.notify(
              ("Pinned: %s  (%d/%d)"):format(name, n, soft_limit),
              vim.log.levels.INFO,
              { title = "Bufferline" }
            )
          end
        end
        vim.cmd("redrawtabline")
      end

      require("bufferline").setup({
        options = {
          mode = "buffers",
          -- Ordinal numbers (1, 2, 3) on each tab so <leader>1..9 maps to
          -- what you see on screen.
          numbers = "ordinal",
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          -- "icon" = vertical bar at the start of the active tab. More robust
          -- across fonts than "underline" (which can bleed into separators).
          indicator = { style = "icon", icon = "▎" },
          diagnostics = false,
          show_buffer_close_icons = false,
          show_close_icon = false,
          -- Always render the tabline so the current file name is visible
          -- (VSCode-like). The bar shows: current buffer + every pinned buffer.
          -- Unpinned buffers disappear from the bar as soon as you switch away.
          always_show_bufferline = true,
          custom_filter = function(buf_number)
            if buf_number == vim.api.nvim_get_current_buf() then
              return true
            end
            return pinned[vim.api.nvim_buf_get_name(buf_number)] == true
          end,
        },
      })

      local function close_buffer()
        pinned[current_path()] = nil
        vim.cmd("bdelete")
      end

      local map = vim.keymap.set
      map("n", "<leader>bb", toggle_pin, { desc = "Bufferline: Toggle pin" })
      map("n", "<leader>bj", "<cmd>BufferLinePick<cr>", { desc = "Bufferline: Pick (letter)" })
      map("n", "<leader>bx", close_buffer, { desc = "Bufferline: Unpin + close buffer" })

      -- Cycle pinned buffers only (custom_filter scopes BufferLineCycle* to
      -- the visible/pinned set, NOT all loaded buffers like :bnext does).
      map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Bufferline: Next pinned" })
      map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Bufferline: Prev pinned" })

      -- Fast close: <C-q> reserved (free in vim default), <C-w> stays as the
      -- vim window-management prefix (splits, navigation, etc.).
      map("n", "<C-q>", close_buffer, { desc = "Close current buffer" })

      -- Direct jumps: <leader>1..9 -> Nth pinned buffer in the bar.
      for i = 1, 9 do
        map("n", "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", {
          desc = "Bufferline: Go to #" .. i,
        })
      end
    end,
  },
}
