return {
  -- Smooth cursor movement animation (smear/trail effect)
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    cond = vim.g.neovide == nil,
    enabled = false,
    opts = {
      stiffness = 0.5,
      trailing_stiffness = 0.49,
      never_draw_over_target = false,
    },
  },
}
