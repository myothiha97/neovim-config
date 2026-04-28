return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  build = "make",
  init = function()
    -- Panels hidden by default, toggled with keymaps
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
          local Sidebar = require("avante.sidebar")

          -- Patch height to return 0 when hidden (so chat panel fills the space)
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

          -- Patch creation to skip mounting when hidden
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

          -- Apply to current sidebar
          local sidebar = require("avante").get()
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
    auto_suggestions_provider = nil, -- don't let avante touch copilot.lua suggestions
    windows = {
      input = {
        height = 20,
      },
    },
    providers = {
      copilot = {
        model = "claude-haiku-4.5",
      },
    },
  },
  keys = {
    {
      "<leader>ae",
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
      desc = "avante: toggle selected files panel",
    },
    {
      "<leader>at",
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
      desc = "avante: toggle todos panel",
    },
  },
}
