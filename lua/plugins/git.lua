return {
  { "lewis6991/gitsigns.nvim", enabled = false },

  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    cmd = { "Neogit" },
    keys = {
      { "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit (status)" },
      { "<leader>gN", "<cmd>Neogit log<cr>", desc = "Neogit log (popup)" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit commit" },
      { "<leader>gp", "<cmd>Neogit pull<cr>", desc = "Neogit pull" },
      { "<leader>gP", "<cmd>Neogit push<cr>", desc = "Neogit push" },
    },
    opts = {
      kind = "tab",
      integrations = { diffview = true },
      disable_commit_confirmation = false,
      signs = {
        section = { "", "" },
        item = { "", "" },
        hunk = { "", "" },
      },
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
