return {
  -- Ensure conform.nvim uses prettierd (faster daemon) instead of prettier
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescript = { "prettierd" },
        typescriptreact = { "prettierd" },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        html = { "prettierd" },
        css = { "prettierd" },
        scss = { "prettierd" },
        markdown = { "prettierd" },
        yaml = { "prettierd" },
        graphql = { "prettierd" },
      },
      -- Configure prettierd to use project-local config with fallback to default
      formatters = {
        prettierd = {
          prepend_args = function()
            local config_files = {
              ".prettierrc",
              ".prettierrc.json",
              ".prettierrc.yml",
              ".prettierrc.yaml",
              ".prettierrc.json5",
              ".prettierrc.js",
              ".prettierrc.cjs",
              ".prettierrc.mjs",
              ".prettierrc.toml",
              "prettier.config.js",
              "prettier.config.cjs",
              "prettier.config.mjs",
            }

            -- Check if project has prettier config
            local cwd = vim.fn.getcwd()
            for _, file in ipairs(config_files) do
              if vim.fn.filereadable(cwd .. "/" .. file) == 1 then
                return {} -- Project config found, let prettierd auto-detect
              end
            end

            -- Check package.json for prettier key
            local pkg = cwd .. "/package.json"
            if vim.fn.filereadable(pkg) == 1 then
              local content = table.concat(vim.fn.readfile(pkg), "\n")
              if content:match('"prettier"') then
                return {} -- Project config in package.json
              end
            end

            -- No project config, use local default
            local default_config = vim.fn.expand("~/.config/prettier/.prettierrc")
            if vim.fn.filereadable(default_config) == 1 then
              return { "--config", default_config }
            end

            return {} -- No config anywhere, use prettierd defaults
          end,
        },
      },
    },
  },

  -- Ensure only prettierd is installed via Mason (not prettier)
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      -- Add prettierd
      table.insert(opts.ensure_installed, "prettierd")
      -- Remove packages we don't use (added by LazyVim extras)
      local exclude = { "prettier", "eslint-lsp" }
      opts.ensure_installed = vim.tbl_filter(function(pkg)
        return not vim.tbl_contains(exclude, pkg)
      end, opts.ensure_installed)
    end,
  },
}
