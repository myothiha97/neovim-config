return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  build = "make",
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    provider = "copilot",
    mode = "agentic",
    auto_suggestions_provider = nil, -- don't let avante touch copilot.lua suggestions
    -- behaviour = {
    --   auto_apply_diff_after_generation = false,
    --   auto_approve_tool_permissions = false, -- Prompt before each file edit
    -- },
  },
}
