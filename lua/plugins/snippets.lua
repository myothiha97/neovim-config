-- Custom snippets configuration
-- Set to false to disable custom ES6/React snippets
local ENABLE_CUSTOM_SNIPPETS = true

return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      if not ENABLE_CUSTOM_SNIPPETS then
        return opts
      end

      -- Ensure the nested structure exists
      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.snippets = opts.sources.providers.snippets or {}
      opts.sources.providers.snippets.opts = opts.sources.providers.snippets.opts or {}

      -- Get existing search_paths or use default
      local search_paths = opts.sources.providers.snippets.opts.search_paths
        or { vim.fn.stdpath("config") .. "/snippets" }

      -- Ensure custom snippets directory is included
      local custom_path = vim.fn.stdpath("config") .. "/snippets"
      if not vim.tbl_contains(search_paths, custom_path) then
        table.insert(search_paths, custom_path)
      end

      opts.sources.providers.snippets.opts.search_paths = search_paths

      return opts
    end,
  },
}
