return {
  -- =============================================
  -- DISABLED PLUGINS (Performance optimization)
  -- =============================================

  -- Disable treesitter-context (not in default LazyVim)
  { "nvim-treesitter/nvim-treesitter-context", enabled = false },

  -- noice.nvim: ONLY cmdline enabled, everything else disabled
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
      routes = {
        -- Suppress all messages to prevent notify utils from running
        { filter = { event = "msg_show" }, opts = { skip = true } },
        { filter = { event = "notify" }, opts = { skip = true } },
      },
    },
  },

  -- MEDIUM: Disable nvim-lint (use ESLint LSP only, avoids duplicate linting)
  { "mfussenegger/nvim-lint", enabled = false },

  -- LOW: Disable persistence/session (can cause micro-freezes on exit)
  { "folke/persistence.nvim", enabled = false },

  -- mini.pairs kept enabled (user preference)

  { "nvim-mini/mini.surround", enabled = false },

  -- Classic vim-surround keymaps: ys, ds, cs, S (visual)
  { "tpope/vim-surround" },
  -- disabling mini.ai due to performance issues with large files
  -- to disabled the plugin without warning, we have to set the author name to a dummy value
  -- if we don't change the author name , the nvim will sitll show a warning that the plugin is disabled
  {
    "nvim-mini/mini.ai",
    enabled = false,
    dir = "/dev/null", -- Or any folder that doesn't exist
    virtual = true,
  },
  { "nvim-mini/mini.nvim", enabled = false },

  -- Disable friendly-snippets (conflicts with custom snippets, uses unsupported transform syntax)
  { "rafamadriz/friendly-snippets", enabled = false },

  -- =============================================
  -- THROTTLED PLUGINS (Reduced update frequency)
  -- =============================================

  -- Throttle lualine updates and avoid high-frequency components.
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

      -- Copilot LSP status indicator (only shown after copilot has loaded)
      table.insert(opts.sections.lualine_x, 1, {
        function()
          local ok, api = pcall(require, "copilot.api")
          if not ok then
            return ""
          end
          local s = api.status.data.status
          local icons = { Normal = " ", InProgress = "󰔟", Warning = "⚠", Error = "✗" }
          return (icons[s] or "?") .. " Copilot"
        end,
        color = function()
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

  -- which-key kept at default 200ms delay (user preference)

  -- =============================================
  -- COMPLETION (blink.cmp)
  -- =============================================

  {
    "saghen/blink.cmp",
    -- dependencies = { "fang2hou/blink-copilot" }, -- disabled: copilot-lsp caused LSP slowdown
    opts = {
      keymap = {
        -- Disable preset to prevent Tab/C-i conflicts
        preset = "none",
        -- Navigation
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        -- Accept
        ["<C-l>"] = { "select_and_accept", "fallback" },
        -- Tab passthrough
        ["<Tab>"] = { "fallback" },
        ["<S-Tab>"] = { "fallback" },
        -- Toggle/close
        ["<C-i>"] = { "show", "hide" },

        -- <Esc>: blink cancels the menu first. If the menu was open, cancel
        -- returns true and the fallback is suppressed (cursor stays in insert,
        -- press Esc again to leave). If the menu was closed, fallback runs
        -- copilot's <Esc> handler which dismisses ghost text + exits insert.
        ["<ESC>"] = { "cancel", "fallback" },
        -- Toggle documentation
        ["<C-h>"] = { "show_documentation", "hide_documentation" },
      },
      snippets = {
        score_offset = 0, -- Remove default -3 penalty on snippet items
      },
      fuzzy = {
        sorts = {
          "exact", -- Exact prefix matches always on top (VSCode-like behavior)
          "score",
          "sort_text",
        },
      },
      completion = {
        accept = {
          auto_brackets = { enabled = false },
        },
        ghost_text = { enabled = false },
        list = {
          max_items = 25,
          selection = {
            preselect = true, -- always highlight first item so <CR> can accept it
            auto_insert = false, -- don't auto-insert text while navigating the list
          },
        },
        trigger = {
          -- Don't re-show completion menu after accepting a completion
          show_on_accept_on_trigger_character = false,
        },
        documentation = {
          -- auto_show = true, --  Show docs automatically when item selected
          auto_show = false, --  use c-h to toggle docs if needed
          -- auto_show_delay_ms = 200, -- Delay before showing docs (ms)
          window = {
            border = "rounded",
            max_width = 80,
            max_height = 30,
          },
        },
        menu = {
          border = "rounded",
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        -- Disable default transform that penalizes snippet scores
        transform_items = function(_, items)
          return items
        end,
        providers = {
          lsp = {
            score_offset = 100,
            min_keyword_length = 0,
            -- Filter out bracket-only completions from emmet (for HTML/CSS files)
            transform_items = function(_, items)
              return vim.tbl_filter(function(item)
                local label = item.label or ""
                if label:match("^[%{%}%(%)%[%]<>]+$") then
                  return false
                end
                return true
              end, items)
            end,
          },
          snippets = {
            score_offset = 100,
            async = true,
            min_keyword_length = 1,
            should_show_items = true,
          },
          buffer = {
            min_keyword_length = 3,
            max_items = 5,
          },
        },
      },
      enabled = function()
        local buftype = vim.bo.buftype
        local filetype = vim.bo.filetype
        if filetype:match("^Avante") or filetype == "AvanteInput" or buftype == "prompt" then
          return false
        end
        return true
      end,
    },
  },
}
