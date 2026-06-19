return {
  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile", -- LazyVim event: fires on file open, deferred past first paint
    opts = {
      -- Sign-column hunk markers only. Blame stays with the custom <leader>gw/gb
      -- floats in keymaps.lua; inline blame is opt-in via <leader>ghb.
      numhl = false,
      linehl = false,
      word_diff = false,
      current_line_blame = false, -- the only per-cursor-move option; off for perf
      current_line_blame_opts = { delay = 300, virt_text_pos = "eol" },
      attach_to_untracked = false,
      update_debounce = 100,
      -- Bordered popup for <leader>ghp so it reads as a distinct window.
      preview_config = {
        border = "rounded",
        style = "minimal",
        relative = "cursor",
        row = 1,
        col = 1,
      },
      on_attach = function(buffer)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
        end

        -- Hunk navigation. NOTE: ]c/[c were previously treesitter class-start moves
        -- (freed in plugins/treesitter.lua); repurposed here for hunks. Inside a diff
        -- split they fall back to native ]c/[c (next/prev diff change) via normal!.
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next hunk")
        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev hunk")

        -- Hunk actions
        map({ "n", "v" }, "<leader>ghs", "<cmd>Gitsigns stage_hunk<cr>", "Stage hunk")
        map({ "n", "v" }, "<leader>ghr", "<cmd>Gitsigns reset_hunk<cr>", "Reset hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo stage hunk")
        -- Bordered popup diff of the hunk. Opens UNFOCUSED; press <Tab> to focus
        -- it (keymaps.lua's <Tab> focuses any float) and navigate with Vim motions.
        -- Inside the popup (CodeCompanion-style):
        --   c1 → toggle stage/unstage the hunk   c2 → revert the hunk   q → close
        -- Diff colors are gitsigns' native theme defaults (readable, not washed out).
        map("n", "<leader>ghp", function()
          local src_win = vim.api.nvim_get_current_win()
          gs.preview_hunk()
          vim.schedule(function()
            local pwin
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              if vim.w[win].gitsigns_preview ~= nil then
                pwin = win
                break
              end
            end
            if not pwin or not vim.api.nvim_win_is_valid(pwin) then
              return
            end
            local pbuf = vim.api.nvim_win_get_buf(pwin)

            -- Clamp width so tiny hunks aren't cramped and huge ones don't sprawl.
            local max_w = math.min(120, vim.o.columns - 8)
            local min_w = math.min(50, max_w)
            local w = math.max(min_w, math.min(max_w, vim.api.nvim_win_get_width(pwin)))
            vim.api.nvim_win_set_width(pwin, w)

            -- Wrap long code lines (with hanging indent) instead of truncating them
            -- at the edge — the global 'nowrap' the popup inherits would hide overflow.
            vim.wo[pwin].wrap = true
            vim.wo[pwin].breakindent = true
            vim.wo[pwin].linebreak = false -- code: break anywhere, not only at spaces

            -- Blank line under the "Hunk X of Y" title (virt line keeps the diff's
            -- highlight extmarks aligned). Recompute height to fit the wrapped lines.
            local pad_ns = vim.api.nvim_create_namespace("gitsigns_preview_pad")
            pcall(vim.api.nvim_buf_set_extmark, pbuf, pad_ns, 0, 0, {
              virt_lines = { { { "", "Normal" } } },
            })
            local rows = 1 -- the title pad virt line
            for _, line in ipairs(vim.api.nvim_buf_get_lines(pbuf, 0, -1, false)) do
              rows = rows + math.max(1, math.ceil(vim.fn.strdisplaywidth(line) / w))
            end
            local max_h = math.max(1, vim.o.lines - vim.o.cmdheight - 4)
            pcall(vim.api.nvim_win_set_height, pwin, math.min(rows, max_h))

            -- Run a Gitsigns action against the source hunk, then close the popup.
            local function act(cmd)
              return function()
                if vim.api.nvim_win_is_valid(src_win) then
                  vim.api.nvim_win_call(src_win, function()
                    vim.cmd(cmd)
                  end)
                end
                pcall(vim.api.nvim_win_close, pwin, true)
              end
            end
            local kopts = { buffer = pbuf, nowait = true, silent = true }
            vim.keymap.set(
              "n",
              "c1",
              act("Gitsigns stage_hunk"),
              vim.tbl_extend("force", kopts, { desc = "Toggle stage/unstage hunk" })
            )
            vim.keymap.set(
              "n",
              "c2",
              act("Gitsigns reset_hunk"),
              vim.tbl_extend("force", kopts, { desc = "Revert hunk" })
            )
          end)
        end, "Preview hunk (Tab focus · c1 stage · c2 revert)")
        map("n", "<leader>ghb", gs.toggle_current_line_blame, "Toggle inline blame")
      end,
    },
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      -- Toggle diff view (same key opens and closes)
      {
        "<leader>gd",
        function()
          local view = require("diffview.lib").get_current_view()
          if view then
            vim.cmd("DiffviewClose")
          else
            vim.cmd("DiffviewOpen")
          end
        end,
        desc = "Toggle Diff View",
      },
      -- Git log with per-commit diff for current file
      { "<leader>gl", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (current file)" },
      -- Git log for entire repo
      { "<leader>gL", "<cmd>DiffviewFileHistory<cr>", desc = "File History (repo)" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
        },
      },
      keymaps = {
        view = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        },
        file_panel = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        },
        file_history_panel = {
          { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } },
        },
      },
    },
  },
}
