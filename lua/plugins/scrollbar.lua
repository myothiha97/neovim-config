return {
  {
    "petertriho/nvim-scrollbar",
    enabled = false,
    event = "BufReadPost",
    opts = {
      show_in_active_only = true,
      handle = {
        blend = 15,
        color = "#565f89",
      },
      marks = {
        Search = { color = "#ff9e64" },
        Error = { color = "#db4b4b" },
        Warn = { color = "#e0af68" },
        Info = { color = "#0db9d7" },
        Hint = { color = "#1abc9c" },
        Misc = { color = "#9d7cd8" },
      },
      excluded_buftypes = {
        "nofile",
        "terminal",
        "prompt",
      },
      excluded_filetypes = {
        "dashboard",
      },
      handlers = {
        cursor = false, -- disable cursor mark (noisy)
        diagnostic = true,
        search = true,
      },
    },
  },
}
