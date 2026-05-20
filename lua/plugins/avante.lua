return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  build = "make",
  enabled = true,
  cmd = {
    "AvanteAsk",
    "AvanteDiff",
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
    provider = "codex",
    auto_suggestions_provider = nil,
    mode = "agentic",

    providers = {
      codex = {
        endpoint = "acp",
        model = "gpt-5.5",
      },
    },

    acp_providers = {
      ["codex"] = {
        command = "codex-acp",
        -- `-c key=value` overrides keys in ~/.codex/config.toml; value is parsed as TOML.
        -- String values need their TOML quotes inside the argument.
        args = {
          "-c",
          'model="gpt-5.5"',
          "-c",
          'model_reasoning_effort="high"', -- "low" | "medium" | "high"
        },
        env = {
          NODE_NO_WARNINGS = "1",
          OPENAI_API_KEY = os.getenv("OPENAI_API_KEY"),
          PATH = os.getenv("PATH"),
          HOME = os.getenv("HOME"),
        },
      },
    },

    behaviour = {
      auto_set_keymaps = false,
      auto_apply_diff_after_generation = true,
    },
    -- Explicitly define conflict mappings here if you don't want standard keys
    mappings = {
      diff = {
        ours = "co", -- Keep your current code block
        theirs = "ct", -- Accept the incoming suggestion
        all_theirs = "ca", -- Accept all suggested blocks globally
        both = "cb", -- Merge both blocks together
        cursor = "cc", -- Accept the block under cursor
        next = "]x", -- Jump to next modification block
        prev = "[x", -- Jump to previous modification block
      },
      sidebar = {
        apply_all = "A", -- Apply all suggestions → opens diff view
        apply_cursor = "a", -- Apply suggestion under cursor → opens diff view
        switch_windows = "<Tab>",
        reverse_switch_windows = "<S-Tab>",
      },
    },

    selection = {
      hint_display = "none",
    },
    windows = {
      input = {
        height = 10,
      },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  keys = {
    { "<leader>aa", "<cmd>AvanteAsk<cr>", desc = "Avante: Ask AI" },
    { "<leader>ac", "<cmd>AvanteChat<cr>", desc = "Avante: Chat" },
    {
      "<c-i>",
      function()
        require("avante.api").ask()
      end,
      mode = "v",
      desc = "Avante: Ask with selection (Edit via agent)",
    },
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
