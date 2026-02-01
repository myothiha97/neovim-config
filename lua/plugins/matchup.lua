return {
  {
    "andymass/vim-matchup",
    event = "BufReadPost",
    init = function()
      vim.g.matchup_matchparen_offscreen = {}
      vim.g.matchup_matchparen_enabled = 0
      -- vim.g.matchup_matchparen_deferred = 1
      -- vim.g.matchup_matchparen_deferred_show_delay = 200
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      matchup = {
        enable = true,
      },
    },
  },
}
