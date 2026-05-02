return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  lazy = false,
  init = function()
    local function set_grep_hl()
      vim.api.nvim_set_hl(0, "SnacksPickerMatch", { link = "DiffText" })
    end
    set_grep_hl()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_grep_hl })
  end,
  opts = {
    explorer = { enabled = true },
    dashboard = { enabled = true },
    scroll = { enabled = false },
    animate = { enabled = false },
    words = { enabled = false }, -- CursorMoved buffer-wide search on every j/k
    indent = { enabled = false }, -- per-scroll indent guide rendering
    scope = { enabled = false }, -- treesitter scope tracking on every cursor move
    dim = { enabled = false },
    picker = {
      sources = {
        ---@class snacks.picker.smart.Config: snacks.picker.Config
        smart = {
          multi = {
            { source = "buffers", hidden = true, current = false },
            { source = "recent", filter = { cwd = true } },
            { source = "files" },
          },
          format = "file",
          matcher = {
            frecency = false,
            sort_empty = false,
          },
        },
        grep = {
          layout = {
            preview = false,
            layout = {
              box = "horizontal",
              width = 0.8,
              height = 0.5,
              {
                box = "vertical",
                border = true,
                title = "{title} {live} {flags}",
                { win = "input", height = 1, border = "bottom" },
                { win = "list", border = "none" },
              },
              { win = "preview", title = "{preview}", border = true, width = 0.45 },
            },
          },
        },
        explorer = {
          layout = {
            layout = {
              width = 0.2,
            },
          },
          actions = {
            explorer_toggle_focus = function(picker)
              local root = vim.uv.cwd()
              if picker:cwd() ~= root then
                local target = picker:cwd()
                picker:set_cwd(root)
                picker:find()
                -- After items load, move cursor to the previously focused folder
                vim.defer_fn(function()
                  local items = picker.list.items
                  for i, item in ipairs(items) do
                    if item.file and item.file == target then
                      picker.list:view(i)
                      return
                    end
                  end
                end, 50)
                return
              else
                picker:set_cwd(picker:dir())
                picker:find()
              end
            end,
          },
          win = {
            list = {
              keys = {
                ["<Esc>"] = false, -- don't close on Esc
                ["q"] = false, -- don't close on q
                ["/"] = false, -- use vim search instead of explorer filter
                ["?"] = false, -- use vim search instead of help
                ["<C-f>"] = { "explorer_close_all", mode = { "n" } },
                ["<C-c>"] = { "close", mode = { "n" } },
                ["."] = { "explorer_toggle_focus", mode = { "n" }, desc = "Toggle focus folder" },
              },
            },
          },
        },
      },
      layout = {
        preview = false,
        layout = {
          width = 0.3,
          height = 0.4,
        },
      },
    },
  },
  keys = {
    -- Disable LazyVim default so diffview.nvim owns <leader>gd
    { "<leader>gd", false },
    { "<leader>gD", false },
    {
      "<leader>xd",
      function()
        Snacks.picker.diagnostics({
          filter = { buf = true },
          layout = {
            preview = true,
            layout = { width = 0.85, height = 0.75 },
          },
        })
      end,
      desc = "Diagnostics (current file)",
    },
    {
      "<leader>xD",
      function()
        Snacks.picker.diagnostics({
          layout = {
            preview = true,
            layout = { width = 0.85, height = 0.75 },
          },
        })
      end,
      desc = "Diagnostics (workspace)",
    },
    {
      "<leader>ss",
      function()
        Snacks.picker.lsp_symbols({
          filter = {
            default = {
              "Function",
              "Method",
              "Class",
              "Interface",
              "Enum",
              "EnumMember",
              "Constructor",
              "TypeParameter",
            },
            typescript = {
              "Function",
              "Method",
              "Class",
              "Interface",
              "Enum",
              "EnumMember",
              "Constructor",
              "TypeParameter",
            },
            typescriptreact = {
              "Function",
              "Method",
              "Class",
              "Interface",
              "Enum",
              "EnumMember",
              "Constructor",
              "TypeParameter",
            },
          },
        })
      end,
      desc = "LSP Symbols (functions/types)",
    },
    {
      "<leader><leader>",
      function()
        require("snacks").picker.smart()
      end,
      desc = "Find Files smart (both recent and open buffers)",
    },
    {
      "<leader>ff",
      function()
        require("snacks").picker.files()
      end,
      desc = "Find Files (root)",
    },
    {
      "<leader>fi",
      function()
        require("snacks").picker.files({ cwd = vim.fn.expand("%:p:h") })
      end,
      desc = "Find Files (current file dir)",
    },
    { "<leader>e", false },
    { "<leader>E", false },
    {
      "<leader>r",
      function()
        require("snacks").picker.explorer()
      end,
      desc = "Toggle Explorer",
    },
    {
      "<leader>fp",
      function()
        require("snacks").picker.projects()
      end,
      desc = "Switch Project",
    },
  },
}
