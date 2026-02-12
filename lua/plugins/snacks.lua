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
    scroll = { enabled = false },
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
          win = {
            list = {
              keys = {
                ["<Esc>"] = false, -- don't close on Esc
                ["/"] = false, -- use vim search instead of explorer filter
                ["?"] = false, -- use vim search instead of help
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
