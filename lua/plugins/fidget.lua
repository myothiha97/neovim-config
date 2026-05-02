return {
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      progress = {
        poll_rate = 0,               -- event-driven, never polls
        suppress_on_insert = true,   -- no distractions while typing
        ignore_done_already = true,
        ignore = { "copilot", "copilot-lsp" },
        display = {
          render_limit = 8,
          done_ttl = 2,
          done_icon = "✓",
          progress_icon = { "dots" },
        },
      },
      notification = {
        poll_rate = 10,
        override_vim_notify = false, -- keep vim.notify as-is
        window = {
          normal_hl = "Comment",
          winblend = 0,
          border = "none",
          align = "bottom",
        },
      },
    },
  },
}
