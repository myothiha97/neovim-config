return {
  {
    "stevearc/conform.nvim",
    opts = function()
      -- Completely disable LazyVim's format on save
      require("lazyvim.util.format").autoformat = false

      return {
        formatters_by_ft = {
          javascript = { "prettierd" },
          typescript = { "prettierd" },
          javascriptreact = { "prettierd" },
          typescriptreact = { "prettierd" },
        },
        -- No format on save - we'll do it manually with <leader>cf
        format_on_save = false,
      }
    end,
  },
}
