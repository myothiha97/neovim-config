return {
  {
    "ThePrimeagen/harpoon",
    enabled = false, -- disabled for now (not used much); frees <leader>m / <leader>h / <leader>1-5
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      local list_mt = getmetatable(harpoon:list())
      local original_add = list_mt.add
      local original_prepend = list_mt.prepend
      local allow_manual_add = false

      list_mt.add = function(self, item)
        if not allow_manual_add then
          return self
        end
        return original_add(self, item)
      end

      list_mt.prepend = function(self, item)
        if not allow_manual_add then
          return self
        end
        return original_prepend(self, item)
      end

      local function add_current_file_to_harpoon()
        local bufnr = vim.api.nvim_get_current_buf()
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        local buftype = vim.bo[bufnr].buftype

        if buftype ~= "" then
          vim.notify("Harpoon only adds normal file buffers", vim.log.levels.WARN, { title = "Harpoon" })
          return
        end

        if bufname == "" then
          vim.notify("Harpoon only adds saved files", vim.log.levels.WARN, { title = "Harpoon" })
          return
        end

        if not vim.uv.fs_stat(bufname) then
          vim.notify("Harpoon only adds files that exist on disk", vim.log.levels.WARN, { title = "Harpoon" })
          return
        end

        allow_manual_add = true
        local ok, err = pcall(function()
          harpoon:list():add()
        end)
        allow_manual_add = false

        if not ok then
          vim.notify(err, vim.log.levels.ERROR, { title = "Harpoon" })
        end
      end

      local function harpoon_item_label(item)
        if type(item) == "table" then
          return item.value or item.path or vim.inspect(item)
        end
        return tostring(item)
      end

      harpoon:extend({
        ADD = function(payload)
          local label = payload and payload.item and harpoon_item_label(payload.item) or "file"
          vim.notify("Added to Harpoon: " .. label, vim.log.levels.INFO, { title = "Harpoon" })
        end,
        REMOVE = function(payload)
          local label = payload and payload.item and harpoon_item_label(payload.item) or "file"
          vim.notify("Removed from Harpoon: " .. label, vim.log.levels.WARN, { title = "Harpoon" })
        end,
      })
      -- CONFLICT: <leader>m is owned by "Add line to Quickfix" (config/keymaps.lua).
      -- Harpoon is disabled, so nothing clashes today; if you re-enable this plugin,
      -- relocate this map (e.g. <leader>ha) before it silently overrides the quickfix one.
      vim.keymap.set("n", "<leader>m", function()
        add_current_file_to_harpoon()
      end, { desc = "Harpoon Add File" })
      vim.keymap.set("n", "<leader>h", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "Harpoon Menu" })

      local harpoon_select_opts = { desc = "which_key_ignore" }
      vim.keymap.set("n", "<leader>1", function()
        harpoon:list():select(1)
      end, harpoon_select_opts)
      vim.keymap.set("n", "<leader>2", function()
        harpoon:list():select(2)
      end, harpoon_select_opts)
      vim.keymap.set("n", "<leader>3", function()
        harpoon:list():select(3)
      end, harpoon_select_opts)
      vim.keymap.set("n", "<leader>4", function()
        harpoon:list():select(4)
      end, harpoon_select_opts)

      vim.keymap.set("n", "<leader>5", function()
        harpoon:list():select(5)
      end, harpoon_select_opts)

      -- Toggle previous & next buffers stored within Harpoon list
      -- vim.keymap.set("n", "<C-Space>p", function()
      --   harpoon:list():prev()
      -- end)
      -- vim.keymap.set("n", "<C-Space>n", function()
      --   harpoon:list():next()
      -- end)
    end,
  },
}
