return {
  -- =============================================
  -- DISABLED PLUGINS (Performance optimization)
  -- =============================================

  -- Disable treesitter-context (not in default LazyVim)
  { "nvim-treesitter/nvim-treesitter-context", enabled = false },

  -- noice.nvim: Only cmdline enabled if u want fancy interface for cmdline (fancy : / ? interface)
  -- All heavy features disabled for performance
  {
    "folke/noice.nvim",
    enabled = false,
    opts = {
      cmdline = { enabled = false },
      messages = { enabled = false },
      popupmenu = { enabled = false },
      notify = { enabled = false },
      lsp = {
        progress = { enabled = false },
        hover = { enabled = false },
        signature = { enabled = false },
        message = { enabled = false },
      },
    },
  },

  -- MEDIUM: Disable nvim-lint (use ESLint LSP only, avoids duplicate linting)
  { "mfussenegger/nvim-lint", enabled = false },

  -- MEDIUM: Disable gitsigns (heavy in large git repos)
  { "lewis6991/gitsigns.nvim", enabled = false },

  -- bufferline: re-enabled (low performance impact)
  { "akinsho/bufferline.nvim", enabled = false },

  -- LOW: Disable persistence/session (can cause micro-freezes on exit)
  { "folke/persistence.nvim", enabled = false },

  -- mini.pairs kept enabled (user preference)

  { "echasnovski/mini.surround", enabled = true },
  { "echasnovski/mini.ai", enabled = false },

  -- Disable friendly-snippets (conflicts with custom snippets, uses unsupported transform syntax)
  { "rafamadriz/friendly-snippets", enabled = false },

  -- =============================================
  -- THROTTLED PLUGINS (Reduced update frequency)
  -- =============================================

  -- Throttle lualine updates (default 100ms -> 500ms)
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        refresh = {
          statusline = 500,
          tabline = 1000,
          winbar = 1000,
        },
      },
    },
  },

  -- which-key kept at default 200ms delay (user preference)

  -- =============================================
  -- COMPLETION (blink.cmp)
  -- =============================================

  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        ["<Tab>"] = {},
        ["<S-Tab>"] = {},
      },
      snippets = {
        score_offset = 0, -- Remove default -3 penalty on snippet items
      },
      completion = {
        ghost_text = { enabled = false },
        list = {
          max_items = 50,
        },
        trigger = {
          -- Don't re-show completion menu after accepting a completion
          show_on_accept_on_trigger_character = false,
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          lsp = {
            score_offset = 100,
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
            score_offset = 200,
            async = false,
            min_keyword_length = 1,
            should_show_items = true,
          },
        },
      },
    },
    config = function(_, opts)
      -- Helper: check if cursor is in a comment using treesitter
      local function in_comment()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        row = row - 1
        col = math.max(col - 1, 0) -- Check char before cursor
        local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, row, col)
        if ok and captures then
          for _, c in ipairs(captures) do
            if c.capture:match("comment") then
              return true
            end
          end
        end
        -- Fallback: check vim syntax
        local syngroup = vim.fn.synIDattr(vim.fn.synID(row + 1, col + 1, true), "name")
        if syngroup:lower():match("comment") then
          return true
        end
        return false
      end

      -- Set enabled function
      opts.enabled = function()
        local buftype = vim.bo.buftype
        local filetype = vim.bo.filetype
        -- Disable in Avante/prompt buffers
        if filetype:match("^Avante") or filetype == "AvanteInput" or buftype == "prompt" then
          return false
        end
        -- Disable in comments
        if in_comment() then
          return false
        end
        return true
      end

      require("blink.cmp").setup(opts)
    end,
  },
}
