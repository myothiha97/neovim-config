local function clear_smart_picker_history()
  local history = require("snacks.picker.util.history").new("picker_smart")
  history.kv.data = {}
  history.idx = 1
  history.cursor = 1
  history.kv:close()

  vim.v.oldfiles = {}
  pcall(vim.cmd, "wshada!")

  vim.notify("Cleared Snacks smart picker history", vim.log.levels.INFO)
end

local snacks_keymaps = {
  ["<C-f>"] = { "close", mode = { "n", "i" } },
  ["<C-l>"] = {
    "confirm",
    mode = { "n", "i" },
    desc = "Confirm selection",
  },
}

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
      win = {
        input = {
          keys = {
            ["<C-l>"] = { "confirm", mode = { "n", "i" }, desc = "Confirm selection" },
          },
        },
        list = {
          keys = {
            ["<C-l>"] = { "confirm", mode = { "n", "i" }, desc = "Confirm selection" },
          },
        },
      },
      sources = {
        ---@class snacks.picker.smart.Config: snacks.picker.Config
        smart = {
          multi = {
            { source = "buffers", hidden = true, current = false },
            { source = "recent", filter = { cwd = true } },
            { source = "files" },
          },
          keys = snacks_keymaps,
          format = "file",
          matcher = {
            frecency = false,
            sort_empty = false,
          },
        },
        grep = {
          keys = snacks_keymaps,
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
              width = 0.25,
            },
          },
          actions = {
            explorer_single_click = function(picker)
              local pos = vim.fn.getmousepos()
              local list_win = picker.list.win.win

              -- Click outside the explorer list: replicate default
              -- <LeftMouse> behavior (focus the clicked window, place
              -- cursor at the click point). We have to do this manually
              -- because intercepting <LeftMouse> suppresses the default.
              if pos.winid ~= list_win then
                if pos.winid > 0 and vim.api.nvim_win_is_valid(pos.winid) then
                  vim.api.nvim_set_current_win(pos.winid)
                  if pos.line > 0 then
                    local col = math.max(0, pos.column - 1)
                    pcall(vim.api.nvim_win_set_cursor, pos.winid, { pos.line, col })
                  end
                end
                return
              end

              if pos.line < 1 then
                return
              end

              local idx = picker.list:row2idx(pos.line)
              local item = picker.list:get(idx)
              if not item or not vim.api.nvim_win_is_valid(list_win) then
                return
              end

              picker.list:view(idx)

              if item.dir or picker.input.filter.meta.searching then
                picker:action("confirm")
                return
              end

              if not vim.api.nvim_win_is_valid(picker.main) then
                return
              end

              local path = Snacks.picker.util.path(item)
              if not path then
                return
              end

              local buf = item.buf or vim.fn.bufadd(path)
              vim.bo[buf].buflisted = true

              if vim.api.nvim_win_get_buf(picker.main) ~= buf then
                local ok, err = pcall(vim.fn.bufload, buf)
                if not ok then
                  Snacks.notify.error("Failed to load `" .. path .. "`:\n- " .. err)
                  return
                end

                ok, err = pcall(vim.api.nvim_win_set_buf, picker.main, buf)
                if not ok then
                  Snacks.notify.error("Failed to open `" .. path .. "`:\n- " .. err)
                  return
                end
              end

              if vim.api.nvim_win_is_valid(list_win) then
                vim.api.nvim_set_current_win(list_win)
              end
            end,
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
                ["<C-l>"] = {
                  function()
                    vim.cmd.wincmd("l")
                  end,
                  desc = "Focus right window",
                },
                ["<C-f>"] = { "explorer_close_all", mode = { "n" } },
                ["<C-c>"] = { "close", mode = { "n" } },
                ["."] = { "explorer_toggle_focus", mode = { "n" }, desc = "Toggle focus folder" },
                -- Intercept <LeftMouse> (press) so the action and folder
                -- toggle happen in a single redraw cycle — no visible
                -- cursor jump between the click column and post-render
                -- column 1. The handler manually replicates default
                -- focus/cursor behavior for clicks outside the list.
                ["<LeftMouse>"] = { "explorer_single_click", mode = { "n" }, desc = "Open or toggle" },
                ["<2-LeftMouse>"] = { "explorer_single_click", mode = { "n" }, desc = "Open or toggle" },
                ["<3-LeftMouse>"] = { "explorer_single_click", mode = { "n" }, desc = "Open or toggle" },
                ["<4-LeftMouse>"] = { "explorer_single_click", mode = { "n" }, desc = "Open or toggle" },
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
    { "<leader>sc", false },
    { "<leader>sC", false },
    { "<leader>so", false },
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
      "<leader>sc",
      function()
        Snacks.picker.commands()
      end,
      desc = "Commands",
    },
    {
      "<leader>sC",
      function()
        clear_smart_picker_history()
      end,
      desc = "Clear Smart Picker History",
    },
    {
      "<leader>so",
      function()
        Snacks.picker.command_history()
      end,
      desc = "Command History",
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
