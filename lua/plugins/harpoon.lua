return {
  {
    "ThePrimeagen/harpoon",
    enabled = true,
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
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
      vim.keymap.set("n", "<leader>m", function()
        harpoon:list():add()
      end)
      vim.keymap.set("n", "<leader>h", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)

      vim.keymap.set("n", "<leader>1", function()
        harpoon:list():select(1)
      end)
      vim.keymap.set("n", "<leader>2", function()
        harpoon:list():select(2)
      end)
      vim.keymap.set("n", "<leader>3", function()
        harpoon:list():select(3)
      end)
      vim.keymap.set("n", "<leader>4", function()
        harpoon:list():select(4)
      end)

      vim.keymap.set("n", "<leader>5", function()
        harpoon:list():select(5)
      end)

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
