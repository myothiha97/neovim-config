return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "none",
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-o>"] = { "select_and_accept", "fallback" },
        ["<CR>"] = { "select_and_accept", "fallback" },
        ["<Tab>"] = { "fallback" },
        ["<S-Tab>"] = { "fallback" },
        ["<C-i>"] = { "show", "hide" },
        -- <Esc>: cancel menu first (second Esc exits insert via copilot's handler)
        ["<ESC>"] = { "cancel", "fallback" },
        ["<C-h>"] = { "show_documentation", "hide_documentation" },
      },
      snippets = {
        score_offset = 0,
      },
      fuzzy = {
        sorts = { "exact", "score", "sort_text" },
      },
      completion = {
        accept = {
          auto_brackets = { enabled = false },
        },
        ghost_text = { enabled = false },
        list = {
          max_items = 25,
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },
        trigger = {
          show_on_accept_on_trigger_character = false,
        },
        documentation = {
          auto_show = false, -- if u want the docs to show up automatically, set this to true
          auto_show_delay_ms = 150,
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
        transform_items = function(_, items)
          return items
        end,
        providers = {
          lsp = {
            score_offset = 100,
            min_keyword_length = 0,
            -- Filter bracket-only completions from emmet
            transform_items = function(_, items)
              return vim.tbl_filter(function(item)
                return not (item.label or ""):match("^[%{%}%(%)%[%]<>]+$")
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
        local ft = vim.bo.filetype
        return not (ft:match("^Avante") or ft == "AvanteInput" or vim.bo.buftype == "prompt")
      end,
    },
  },
}
