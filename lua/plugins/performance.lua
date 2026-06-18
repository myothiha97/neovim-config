return {
  { "nvim-treesitter/nvim-treesitter-context", enabled = false },

  -- noice.nvim: cmdline popup only, everything else off
  {
    "folke/noice.nvim",
    enabled = true,
    event = "VeryLazy",
    opts = {
      health = { checker = false }, -- Disable health check (causes 1.5s overhead)
      cmdline = { enabled = true },
      views = {
        cmdline_popup = {
          position = { row = "10%", col = "50%" },
          size = { width = 60, height = "auto" },
        },
      },
      messages = { enabled = false },
      popupmenu = { enabled = false },
      notify = { enabled = false },
      smart_move = { enabled = false },
      lsp = {
        progress = { enabled = false },
        hover = { enabled = false },
        signature = { enabled = false },
        message = { enabled = false },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
          ["vim.lsp.util.stylize_markdown"] = false,
          ["cmp.entry.get_documentation"] = false,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = false,
        long_message_to_split = false,
        inc_rename = false,
        lsp_doc_border = false,
      },
      routes = {},
    },
  },

  { "mfussenegger/nvim-lint", enabled = false },
  { "folke/persistence.nvim", enabled = false },
  { "nvim-mini/mini.surround", enabled = false },
  { "nvim-mini/mini.nvim", enabled = false },
  { "rafamadriz/friendly-snippets", enabled = false },

  -- mini.ai disabled: performance issues with large files.
  -- dir="/dev/null" + virtual=true prevents LazyVim from showing a warning.
  { "nvim-mini/mini.ai", enabled = false, dir = "/dev/null", virtual = true },

  -- Classic vim-surround: ys, ds, cs, s (visual — remapped from default S)
  {
    "tpope/vim-surround",
    config = function()
      vim.keymap.set("x", "s", "<Plug>VSurround", { desc = "Surround selection" })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    init = function()
      -- LazyVim's Trouble breadcrumb is useful, but it rebuilds Trouble symbols
      -- during statusline draws and showed up as a runtime hotspot.
      vim.g.trouble_lualine = false

      vim.api.nvim_create_autocmd({ "BufModifiedSet", "BufWritePost" }, {
        callback = function()
          vim.cmd.redrawstatus()
        end,
      })
    end,
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.refresh = {
        statusline = 1000,
        tabline = 1000,
        winbar = 1000,
        events = {
          "WinEnter",
          "BufEnter",
          "BufWritePost",
          "SessionLoadPost",
          "FileChangedShellPost",
          "VimResized",
          "Filetype",
          "ModeChanged",
        },
      }
      opts.sections = opts.sections or {}
      opts.sections.lualine_x = vim.tbl_filter(function(component)
        return not (component == "diff" or (type(component) == "table" and component[1] == "diff"))
      end, opts.sections.lualine_x or {})
      opts.sections.lualine_b = opts.sections.lualine_b or {}
      table.insert(opts.sections.lualine_b, {
        function()
          return "● unsaved"
        end,
        color = { fg = "#ff4444" },
        cond = function()
          return vim.bo.modified
        end,
      })

      local lualine_c = opts.sections.lualine_c or {}
      for i, component in ipairs(lualine_c) do
        if component == "diagnostics" or (type(component) == "table" and component[1] == "diagnostics") then
          table.insert(lualine_c, i + 1, {
            function()
              return "  "
            end,
            separator = "",
            padding = { left = 0, right = 0 },
          })
          break
        end
      end
      for _, component in ipairs(lualine_c) do
        if type(component) == "table" and component[1] == "filetype" then
          component.padding = { left = 0, right = 0 }
          break
        end
      end
      for i = #lualine_c, 1, -1 do
        local component = lualine_c[i]
        if
          type(component) == "table"
          and component[1] ~= "filetype"
          and type(component[1]) == "function"
          and component.cond == nil
        then
          lualine_c[i] = {
            "filename",
            path = 0,
            color = { fg = "#89b4fa", gui = "bold" },
            padding = { left = 0, right = 0 },
          }
          break
        end
      end
      opts.sections.lualine_c = lualine_c

      -- Custom percent badge styling: keep the same statusline background as the
      -- line indicator, but use a Solarized Osaka accent for the text.
      -- If the colorscheme or lualine theme changes, revisit this block.
      -- Previous green fallback, if yellow reads worse:
      -- { fg = "#849900", bg = "#002c38", gui = "bold" }
      local percent_color = { fg = "#b28500", bg = "#002c38", gui = "bold" }
      local ok, solarized_colors = pcall(require, "solarized-osaka.colors")
      if ok then
        local colors = solarized_colors.setup({ transform = true })
        percent_color = { fg = colors.yellow500 or colors.yellow, bg = colors.bg_statusline, gui = "bold" }
      end

      opts.sections.lualine_y = {
        {
          function()
            local current = vim.fn.line(".")
            local total = vim.api.nvim_buf_line_count(0)
            return string.format("line %d/%d", current, total)
          end,
          padding = { left = 1, right = 1 },
        },
        {
          function()
            local current = vim.fn.line(".")
            local total = vim.api.nvim_buf_line_count(0)
            local percent = total > 0 and math.floor((current / total) * 100 + 0.5) or 0
            return string.format("%d%%%%", percent)
          end,
          color = percent_color,
          padding = { left = 2, right = 1 },
        },
      }

      -- Copilot status indicator (LSP status + autocomplete toggle state)
      -- Color reflects vim.g.copilot_enabled (toggled via <leader>ad / <C-k>):
      --   enabled  -> color from LSP status (green/yellow/red)
      --   disabled -> dim gray + power-off icon
      table.insert(opts.sections.lualine_x, 1, {
        function()
          local ok, api = pcall(require, "copilot.api")
          if not ok then
            return ""
          end
          if not vim.g.copilot_enabled then
            return " Copilot"
          end
          local s = api.status.data.status
          local icons = { Normal = " ", InProgress = "󰔟", Warning = "⚠", Error = "✗" }
          return (icons[s] or "?") .. " Copilot"
        end,
        color = function()
          if not vim.g.copilot_enabled then
            return { fg = "#6c7086" }
          end
          local ok, api = pcall(require, "copilot.api")
          if not ok then
            return { fg = "#888888" }
          end
          local s = api.status.data.status
          if s == "Normal" then
            return { fg = "#6cc644" }
          elseif s == "Warning" then
            return { fg = "#f0c040" }
          elseif s == "Error" then
            return { fg = "#ff6b6b" }
          end
          return { fg = "#888888" }
        end,
        cond = function()
          return package.loaded["copilot.api"] ~= nil
        end,
      })
      return opts
    end,
  },
}
