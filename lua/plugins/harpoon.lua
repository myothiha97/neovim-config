return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    keys = {
      {
        "<leader>m",
        function()
          require("harpoon"):list():add()
          vim.notify("Marked: " .. vim.fn.expand("%:."))
        end,
        desc = "Harpoon File",
      },
      {
        "<leader>h",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon Quick Menu",
      },
      {
        "<leader>M",
        function()
          require("harpoon"):list():remove()
          vim.notify("Removed: " .. vim.fn.expand("%:."))
        end,
        desc = "Harpoon Remove File",
      },
      {
        "<leader>1",
        function()
          require("harpoon"):list():select(1)
        end,
        desc = "which_key_ignore",
      },
      {
        "<leader>2",
        function()
          require("harpoon"):list():select(2)
        end,
        desc = "which_key_ignore",
      },
      {
        "<leader>3",
        function()
          require("harpoon"):list():select(3)
        end,
        desc = "which_key_ignore",
      },
      {
        "<leader>4",
        function()
          require("harpoon"):list():select(4)
        end,
        desc = "which_key_ignore",
      },
      {
        "<leader>5",
        function()
          require("harpoon"):list():select(5)
        end,
        desc = "which_key_ignore",
      },
      { "<leader>6", function() require("harpoon"):list():select(6) end, desc = "which_key_ignore" },
      { "<leader>7", function() require("harpoon"):list():select(7) end, desc = "which_key_ignore" },
      { "<leader>8", function() require("harpoon"):list():select(8) end, desc = "which_key_ignore" },
      { "<leader>9", function() require("harpoon"):list():select(9) end, desc = "which_key_ignore" },
    },
  },
}
