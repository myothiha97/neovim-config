return {
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    enabled = true,
    init = function()
      -- Disable fold highlight - run after colorscheme loads
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          vim.api.nvim_set_hl(0, "Folded", { bg = "NONE" })
          vim.api.nvim_set_hl(0, "UfoFoldedBg", { bg = "NONE" })
          vim.api.nvim_set_hl(0, "UfoFoldCount", { fg = "#c9ba9b", italic = true })
        end,
      })
      -- Also set immediately for current colorscheme
      vim.api.nvim_set_hl(0, "Folded", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "UfoFoldedBg", { bg = "NONE" })
      -- Warm bright color for the "N lines" fold count indicator
      vim.api.nvim_set_hl(0, "UfoFoldCount", { fg = "#c9ba9b", italic = true })

      -- TODO: Auto-fold top import block on file open
      -- Needs investigation: za works manually but auto-fold breaks after manual unfold + reopen
    end,
    keys = {
      {
        "zR",
        function()
          require("ufo").openAllFolds()
        end,
        desc = "Open all folds",
      },
      {
        "zM",
        function()
          require("ufo").closeAllFolds()
        end,
        desc = "Close all folds",
      },
      {
        "zK",
        function()
          require("ufo").peekFoldedLinesUnderCursor()
        end,
        desc = "Peek fold",
      },
      {
        "zv",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          local lang_queries = {
            typescript = "[(function_declaration) (function_expression) (arrow_function) (method_definition)] @func",
            tsx = "[(function_declaration) (function_expression) (arrow_function) (method_definition)] @func",
            javascript = "[(function_declaration) (function_expression) (arrow_function) (method_definition)] @func",
            jsx = "[(function_declaration) (function_expression) (arrow_function) (method_definition)] @func",
            lua = "[(function_declaration) (local_function)] @func",
            python = "(function_definition) @func",
            go = "[(function_declaration) (method_declaration)] @func",
            rust = "(function_item) @func",
          }

          local func_lines = {}
          local ok_p, parser = pcall(vim.treesitter.get_parser, bufnr)
          if ok_p and parser then
            local lang = parser:lang()
            local query_str = lang_queries[lang]
            if query_str then
              local ok_q, query = pcall(vim.treesitter.query.parse, lang, query_str)
              if ok_q and query then
                local tree = parser:parse()[1]
                if tree then
                  local root = tree:root()
                  for _, node in query:iter_captures(root, bufnr, 0, -1) do
                    local lnum = node:start() + 1
                    if vim.fn.foldlevel(lnum) > 0 then
                      table.insert(func_lines, lnum)
                    end
                  end
                end
              end
            end
          end

          -- Fallback: top-level folds when treesitter has no query for this language
          if #func_lines == 0 then
            local line_count = vim.api.nvim_buf_line_count(bufnr)
            for lnum = 1, line_count do
              if vim.fn.foldlevel(lnum) > 0 and (lnum == 1 or vim.fn.foldlevel(lnum - 1) == 0) then
                table.insert(func_lines, lnum)
              end
            end
          end

          if #func_lines == 0 then
            return
          end

          local any_open = false
          for _, lnum in ipairs(func_lines) do
            if vim.fn.foldclosed(lnum) == -1 then
              any_open = true
              break
            end
          end

          local saved_cursor = vim.api.nvim_win_get_cursor(0)
          for _, lnum in ipairs(func_lines) do
            if vim.fn.foldlevel(lnum) > 0 then
              vim.api.nvim_win_set_cursor(0, { lnum, 0 })
              if any_open then
                if vim.fn.foldclosed(lnum) == -1 then
                  pcall(vim.cmd, "normal! zc")
                end
              else
                if vim.fn.foldclosed(lnum) ~= -1 then
                  pcall(vim.cmd, "normal! zo")
                end
              end
            end
          end
          vim.api.nvim_win_set_cursor(0, saved_cursor)
        end,
        desc = "Toggle all function folds",
      },
    },
    opts = {
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ("  %d lines "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "UfoFoldCount" })
        return newVirtText
      end,
      open_fold_hl_timeout = 0,
    },
  },

  {
    "luukvbaal/statuscol.nvim",
    enabled = false,
    event = "BufReadPost",
    init = function()
      -- Toggle fold column with <leader>uo
      vim.keymap.set("n", "<leader>uo", function()
        if vim.o.foldcolumn == "0" then
          vim.o.foldcolumn = "1"
        else
          vim.o.foldcolumn = "0"
        end
      end, { desc = "Toggle fold column" })
    end,
    opts = function()
      local builtin = require("statuscol.builtin")
      return {
        relculright = true,
        segments = {
          { text = { "%s" }, click = "v:lua.ScSa" },
          { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
          { text = { " ", builtin.foldfunc, " " }, click = "v:lua.ScFa" },
        },
      }
    end,
  },
}
