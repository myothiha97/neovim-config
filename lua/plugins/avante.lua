return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  build = "make",
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    provider = "copilot",
    auto_suggestions_provider = nil, -- don't let avante touch copilot.lua suggestions
  },
}
