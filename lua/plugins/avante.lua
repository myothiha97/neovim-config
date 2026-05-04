return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  build = "make",
  enabled = true,
  cmd = {
    "AvanteAsk",
    "AvanteChat",
    "AvanteClear",
    "AvanteEdit",
    "AvanteFocus",
    "AvanteHistory",
    "AvanteModels",
    "AvanteRefresh",
    "AvanteStop",
    "AvanteSwitchProvider",
    "AvanteToggle",
  },
  init = function()
    vim.g.avante_show_selected_files = false
    vim.g.avante_show_todos = false

    local patched = false
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "Avante",
      callback = function()
        if patched then
          return
        end
        patched = true

        vim.schedule(function()
          local ok, Sidebar = pcall(require, "avante.sidebar")
          if not ok then
            return
          end

          local orig_sf_height = Sidebar.get_selected_files_container_height
          Sidebar.get_selected_files_container_height = function(self)
            if not vim.g.avante_show_selected_files then
              return 0
            end
            return orig_sf_height(self)
          end

          local orig_todos_height = Sidebar.get_todos_container_height
          Sidebar.get_todos_container_height = function(self)
            if not vim.g.avante_show_todos then
              return 0
            end
            return orig_todos_height(self)
          end

          local orig_create_sf = Sidebar.create_selected_files_container
          Sidebar.create_selected_files_container = function(self)
            if not vim.g.avante_show_selected_files then
              if self.containers.selected_files then
                self.containers.selected_files:unmount()
                self.containers.selected_files = nil
              end
              self.file_selector:off("update")
              self.file_selector:on("update", function()
                self:create_selected_files_container()
              end)
              return
            end
            return orig_create_sf(self)
          end

          local orig_create_todos = Sidebar.create_todos_container
          Sidebar.create_todos_container = function(self)
            if not vim.g.avante_show_todos then
              if self.containers.todos then
                self.containers.todos:unmount()
                self.containers.todos = nil
              end
              return
            end
            return orig_create_todos(self)
          end

          local avante = require("avante")
          local sidebar = avante and avante.get and avante.get()
          if sidebar then
            if sidebar.containers.selected_files then
              sidebar.containers.selected_files:unmount()
              sidebar.containers.selected_files = nil
            end
            if sidebar.containers.todos then
              sidebar.containers.todos:unmount()
              sidebar.containers.todos = nil
            end
            sidebar:adjust_layout()
          end
        end)
      end,
    })
  end,
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    provider = "copilot",
    mode = "agentic",
    -- Prevent avante from using copilot for per-keystroke suggestions
    auto_suggestions_provider = nil,
    behaviour = {
      -- We define all keymaps manually in `keys` below
      auto_set_keymaps = false,
    },
    selection = {
      hint_display = "none",
    },
    windows = {
      input = {
        height = 20,
      },
    },
    -- Model is persisted to ~/.local/state/nvim/avante/config.json automatically.
    -- Run :AvanteModels to select a model — never configure it here (causes model_not_supported).
    mappings = {
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca",
        both = "cb",
        cursor = "cc",
        next = "]x",
        prev = "[x",
      },
      sidebar = {
        apply_all = "A",
        apply_cursor = "a",
        switch_windows = "<Tab>",
        reverse_switch_windows = "<S-Tab>",
      },
      submit = {
        normal = "<CR>",
        insert = "<C-s>",
      },
      cancel = {
        normal = { "<C-c>", "q" },
        insert = "<C-c>",
      },
    },
  },
  keys = {
    { "<leader>aa", "<cmd>AvanteAsk<cr>", desc = "Avante: Ask AI" },
    { "<leader>aa", "<cmd>AvanteAsk<cr>", mode = "v", desc = "Avante: Ask AI (selection)" },
    { "<leader>ac", "<cmd>AvanteChat<cr>", desc = "Avante: Chat" },
    { "<leader>ae", "<cmd>AvanteEdit<cr>", mode = "v", desc = "Avante: Edit selection" },
    { "<leader>at", "<cmd>AvanteToggle<cr>", desc = "Avante: Toggle sidebar" },
    { "<leader>ar", "<cmd>AvanteRefresh<cr>", desc = "Avante: Refresh" },
    { "<leader>aX", "<cmd>AvanteStop<cr>", desc = "Avante: Stop" },
    { "<leader>am", "<cmd>AvanteModels<cr>", desc = "Avante: Select model" },
    { "<leader>ap", "<cmd>AvanteSwitchProvider<cr>", desc = "Avante: Switch provider" },
    { "<leader>ah", "<cmd>AvanteHistory<cr>", desc = "Avante: History" },
    -- Sub-panel visibility toggles (hidden by default, use these to reveal)
    {
      "<leader>aF",
      function()
        vim.g.avante_show_selected_files = not vim.g.avante_show_selected_files
        local sidebar = require("avante").get()
        if not sidebar or not sidebar:is_open() then
          return
        end
        if vim.g.avante_show_selected_files then
          sidebar:create_selected_files_container()
        else
          if sidebar.containers.selected_files then
            sidebar.containers.selected_files:unmount()
            sidebar.containers.selected_files = nil
          end
        end
        sidebar:adjust_layout()
      end,
      desc = "Avante: Toggle files panel",
    },
    {
      "<leader>aO",
      function()
        vim.g.avante_show_todos = not vim.g.avante_show_todos
        local sidebar = require("avante").get()
        if not sidebar or not sidebar:is_open() then
          return
        end
        if vim.g.avante_show_todos then
          sidebar:create_todos_container()
        else
          if sidebar.containers.todos then
            sidebar.containers.todos:unmount()
            sidebar.containers.todos = nil
          end
        end
        sidebar:adjust_layout()
      end,
      desc = "Avante: Toggle todos panel",
    },
  },
}
