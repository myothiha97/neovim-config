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
          -- Walk up from the file's directory, same as VS Code prettier resolution
          prepend_args = function(_, ctx)
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

            local dir = ctx.dirname
            while dir and dir ~= "/" do
              for _, file in ipairs(config_files) do
                if vim.fn.filereadable(dir .. "/" .. file) == 1 then
                  return {} -- Found config, let prettierd auto-detect
                end
              end
              local pkg = dir .. "/package.json"
              if vim.fn.filereadable(pkg) == 1 then
                local content = table.concat(vim.fn.readfile(pkg), "\n")
                if content:match('"prettier"') then
                  return {} -- Config in package.json
                end
              end
              dir = vim.fn.fnamemodify(dir, ":h")
            end

            -- No project config found, fall back to global
            local default_config = vim.fn.expand("~/.config/prettier/.prettierrc")
            if vim.fn.filereadable(default_config) == 1 then
              return { "--config", default_config }
            end

            return {}
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
