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
      vim.g.lsp_loading = ""

      -- Ignore clients that never send a "end" progress event
      local ignored = { copilot = true, ["copilot-lsp"] = true }

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and not ignored[client.name] then
            vim.g.lsp_loading = "⟳ " .. client.name
            vim.cmd.redrawstatus()
          end
        end,
      })

      vim.api.nvim_create_autocmd("LspProgress", {
        callback = function(ev)
          local val = ev.data and ev.data.params and ev.data.params.value
          if not val then
            return
          end
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client or ignored[client.name] then
            return
          end
          if val.kind == "end" then
            vim.g.lsp_loading = ""
          else
            local msg = val.title or ""
            if val.percentage then
              msg = msg .. " " .. val.percentage .. "%"
            end
            vim.g.lsp_loading = "⟳ " .. client.name .. (msg ~= "" and ": " .. msg or "")
          end
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
      opts.sections.lualine_c = opts.sections.lualine_c or {}
      table.insert(opts.sections.lualine_c, {
        function()
          return vim.g.lsp_loading or ""
        end,
        cond = function()
          return (vim.g.lsp_loading or "") ~= ""
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
    init = function()
      local function update_comment_state()
        local buf = vim.api.nvim_get_current_buf()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        row = row - 1
        col = math.max(col - 1, 0)

        local in_comment = false
        local ok, captures = pcall(vim.treesitter.get_captures_at_pos, buf, row, col)
        if ok and captures then
          for _, c in ipairs(captures) do
            if c.capture:match("^comment") then
              in_comment = true
              break
            end
          end
        end

        vim.b[buf].blink_in_comment = in_comment
      end

      -- CursorHoldI fires only after updatetime (200ms) of idle in insert mode
      -- Zero treesitter queries during active typing
      vim.api.nvim_create_autocmd("CursorHoldI", { callback = update_comment_state })
      -- Reset state immediately on InsertEnter so initial position is correct
      vim.api.nvim_create_autocmd("InsertEnter", { callback = update_comment_state })
      -- Optimistically re-enable when cursor moves (no treesitter query — just a flag reset)
      -- Prevents blink staying disabled after moving from a comment to code without pausing
      vim.api.nvim_create_autocmd("CursorMovedI", {
        callback = function()
          local buf = vim.api.nvim_get_current_buf()
          if vim.b[buf].blink_in_comment then
            vim.b[buf].blink_in_comment = false
          end
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
