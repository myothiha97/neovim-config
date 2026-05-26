return {
  {
    "folke/sidekick.nvim",
    event = "VeryLazy",
    enabled = false,
    init = function()
      vim.lsp.config("copilot", {
        cmd = { "copilot-language-server", "--stdio" },
        root_markers = { ".git", "package.json" },
        init_options = {
          editorInfo = {
            name = "Neovim",
            version = tostring(vim.version()),
          },
          editorPluginInfo = {
            name = "Neovim",
            version = tostring(vim.version()),
          },
        },
      })
      vim.lsp.enable("copilot")
    end,
    opts = {
      nes = {
        debounce = 100,
        trigger = {
          events = { "InsertLeave", "TextChanged", "User SidekickNesDone" },
        },
        clear = {
          events = { "TextChangedI", "TextChanged", "BufWritePre", "InsertEnter" },
          esc = true,
        },
      },
      signs = { enabled = false },
      copilot = {
        status = { enabled = false },
      },
    },
    keys = {
      {
        "<tab>",
        function()
          if require("sidekick").nes_jump_or_apply() then
            return
          end
          return "<tab>"
        end,
        mode = { "i", "n" },
        expr = true,
        desc = "NES: Jump/Apply Next Edit",
      },
      {
        "<leader>aa",
        function()
          local sk = require("sidekick")
          local count = 0
          local function apply_next()
            count = count + 1
            if count > 100 then return end
            if sk.nes_jump_or_apply() then
              vim.schedule(apply_next)
            end
          end
          apply_next()
        end,
        desc = "NES: Apply All Edits",
      },
      {
        "<leader>aC",
        function() require("sidekick.cli").toggle() end,
        desc = "Sidekick: Toggle CLI",
      },
      {
        "<leader>at",
        function() require("sidekick.cli").send() end,
        mode = { "n", "v" },
        desc = "Sidekick: Send Context",
      },
      {
        "<leader>ap",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "v" },
        desc = "Sidekick: Select Prompt",
      },
      {
        "<leader>ax",
        function() require("sidekick.cli").select() end,
        desc = "Sidekick: Select Tool",
      },
      {
        "<leader>aq",
        function() require("sidekick.cli").close() end,
        desc = "Sidekick: Close CLI",
      },
    },
  },
}
