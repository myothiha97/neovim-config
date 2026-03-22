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

  -- bufferline: re-enabled (low performance impact)
  { "akinsho/bufferline.nvim", enabled = false },

  -- LOW: Disable persistence/session (can cause micro-freezes on exit)
  { "folke/persistence.nvim", enabled = false },

  -- mini.pairs kept enabled (user preference)

  { "nvim-mini/mini.surround", enabled = true },
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
    init = function()
      -- Performance: Cache comment state, updated on CursorMovedI (not every keystroke)
      -- This avoids expensive treesitter queries on each keypress
      vim.api.nvim_create_autocmd("CursorMovedI", {
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          local row, col = unpack(vim.api.nvim_win_get_cursor(0))
          row = row - 1
          col = math.max(col - 1, 0)

          -- Check treesitter first
          local in_comment = false
          local ok, captures = pcall(vim.treesitter.get_captures_at_pos, buf, row, col)
          if ok and captures then
            for _, c in ipairs(captures) do
              if c.capture:match("comment") then
                in_comment = true
                break
              end
            end
          end

          -- Fallback to vim syntax if treesitter didn't find comment
          if not in_comment then
            local syngroup = vim.fn.synIDattr(vim.fn.synID(row + 1, col + 1, true), "name")
            if syngroup:lower():match("comment") then
              in_comment = true
            end
          end

          vim.b[buf].blink_in_comment = in_comment
        end,
      })
    end,
    opts = {
      keymap = {
        -- Disable preset to prevent Tab/C-i conflicts
        preset = "none",
        -- Navigation
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        -- Accept
        ["<CR>"] = { "accept", "fallback" },
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
      completion = {
        accept = {
          auto_brackets = { enabled = false },
        },
        ghost_text = { enabled = false },
        list = {
          max_items = 50,
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
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
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
            score_offset = 1000,
            async = true, -- Performance: async snippet processing
            min_keyword_length = 1,
            should_show_items = true,
          },
        },
      },
      -- Performance: Read cached comment state instead of querying treesitter
      enabled = function()
        local buftype = vim.bo.buftype
        local filetype = vim.bo.filetype
        -- Disable in Avante/prompt buffers
        if filetype:match("^Avante") or filetype == "AvanteInput" or buftype == "prompt" then
          return false
        end
        -- Disable in comments (cached value from CursorMovedI)
        if vim.b.blink_in_comment then
          return false
        end
        return true
      end,
    },
  },
}
