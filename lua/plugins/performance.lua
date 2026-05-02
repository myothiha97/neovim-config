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

  -- Throttle lualine updates (default 100ms -> 500ms)
  {
    "nvim-lualine/lualine.nvim",
    init = function()
      vim.api.nvim_create_autocmd({ "BufModifiedSet", "BufWritePost" }, {
        callback = function()
          vim.cmd.redrawstatus()
        end,
      })
    end,
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.refresh = {
        statusline = 500,
        tabline = 1000,
        winbar = 1000,
      }
      opts.sections = opts.sections or {}
      opts.sections.lualine_b = opts.sections.lualine_b or {}
      table.insert(opts.sections.lualine_b, {
        function() return "● unsaved" end,
        color = { fg = "#ff4444" },
        cond = function() return vim.bo.modified end,
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
        ["<CR>"] = { "select_and_accept", "fallback" },
        -- Tab passthrough
        ["<Tab>"] = { "fallback" },
        ["<S-Tab>"] = { "fallback" },
        -- Toggle/close
        ["<C-i>"] = { "show", "hide" },
        ["<C-e>"] = { "cancel", "fallback" },
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
          max_items = 50,
          selection = {
            preselect = true, -- always highlight first item so <CR> can accept it
            auto_insert = false, -- don't auto-insert text while navigating the list
          },
        },
        trigger = {
          -- Don't re-show completion menu after accepting a completion
          show_on_accept_on_trigger_character = false,
          -- Show completions immediately with no blink-side delay
          show_delay_ms = 0,
        },
        documentation = {
          auto_show = true, -- Show docs automatically when item selected
          auto_show_delay_ms = 200,
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
        transform_items = function(_, items) return items end,
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
            max_items = 10,
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
