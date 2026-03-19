return {
  -- =============================================
  -- GITSIGNS: inline gutter diff signs
  -- =============================================
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost",
    opts = {
      -- Performance: high debounce avoids frequent git diff calls
      update_debounce = 800,
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      -- Disable expensive features
      word_diff = false,
      current_line_blame = false,
      attach_to_untracked = false,
    },
    keys = {
      -- Navigate hunks
      { "grn", "<cmd>Gitsigns next_hunk<cr>", desc = "Next Hunk" },
      { "grp", "<cmd>Gitsigns prev_hunk<cr>", desc = "Prev Hunk" },
      -- Preview inline diff popup (like VSCode clicking the gutter bar)
      { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview Hunk" },
      -- Stage / reset hunk (like VSCode's stage change button)
      { "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", desc = "Stage Hunk", mode = { "n", "v" } },
      { "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", desc = "Reset Hunk", mode = { "n", "v" } },
      -- Stage / reset entire file
      { "<leader>gS", "<cmd>Gitsigns stage_buffer<cr>", desc = "Stage Buffer" },
      { "<leader>gR", "<cmd>Gitsigns reset_buffer<cr>", desc = "Reset Buffer" },
    },
  },

  -- =============================================
  -- DIFFVIEW: full diff viewer (VSCode Source Control panel)
  -- =============================================
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
    },
  },
}
