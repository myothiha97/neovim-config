-- File outline — the IDE "Structure" pane (WebStorm Alt+7 / VS Code Outline).
--
-- Reuses trouble.nvim's `symbols` mode (already installed via LazyVim): no new plugin, and
-- nothing runs on the scroll/keypress hot path — the panel only works while it's open and
-- Trouble throttles its own updates. Safe for big files.
--
-- Toggle with <leader>cs. The ONLY display override is making the followed-symbol highlight
-- visible (your themes set the global CursorLine bg to NONE, which hides Trouble's marker).
--
-- Filtering: DEFAULT view = LazyVim's standard symbol kinds (functions, methods, classes,
-- fields, properties, enums, ...) — variables are NOT shown. Press `a` inside the panel to
-- ALSO include variables/constants/everything, `a` again to go back. (Variables are opt-in
-- because vtsls reports React arrow components/handlers as Variable too, so showing them by
-- default buries the structure in state/data.)

-- LazyVim's default symbol kinds (always shown). Package is dropped on purpose — it's the
-- file/package declaration (and lua_ls control-flow blocks): never a useful outline entry.
local DEFAULT_KINDS = {
  Class = true,
  Constructor = true,
  Enum = true,
  EnumMember = true,
  Field = true,
  Function = true,
  Interface = true,
  Method = true,
  Module = true,
  Namespace = true,
  Property = true,
  Struct = true,
  Trait = true,
}

-- Toggled by `a`; read by the symbols `filter` on every refresh.
local show_all = false

return {
  "folke/trouble.nvim",
  opts = {
    modes = {
      symbols = {
        win = {
          position = "right",
          size = 0.28, -- dock right, ~28% of editor width
          wo = {
            -- `follow` marks the current symbol via cursorline. Your themes set the global
            -- CursorLine bg to NONE, so re-enable a VISIBLE current-line ONLY in this panel
            -- (winhighlight remaps CursorLine -> Visual here), leaving code buffers untouched.
            cursorline = true,
            cursorlineopt = "line",
            winhighlight = "CursorLine:Visual",
            -- Hybrid line numbers for count-jumps (7j / 8k) after focusing the panel (<C-w>l).
            number = true,
            relativenumber = true,
          },
        },
        -- focus=false keeps your cursor in the code so the panel can FOLLOW you and the
        -- highlight tracks as you move. (focus=true would jump into the panel, freezing it.)
        focus = false,
        follow = true,
        auto_refresh = true,
        -- Default: standard kinds only. `a` flips `show_all` to include variables/everything.
        filter = function(items)
          if show_all then
            return items
          end
          return vim.tbl_filter(function(item)
            return DEFAULT_KINDS[item.kind] == true
          end, items)
        end,
        keys = {
          a = {
            desc = "Outline: toggle variables / all symbols",
            action = function(view)
              show_all = not show_all
              view:refresh()
              vim.notify(
                "Outline: " .. (show_all and "all symbols (incl. variables)" or "default kinds"),
                vim.log.levels.INFO
              )
            end,
          },
        },
        -- Trim each row to icon + name (the default also appends the signature + [pos], which
        -- overflow a narrow panel). Empty-named symbols fall back to their signature text.
        format = "{kind_icon} {symbol.name}",
        formatters = {
          ["symbol.name"] = function(ctx)
            local name = ctx.value
            if type(name) == "string" and name ~= "" then
              return name
            end
            local text = ctx.item.text
            if type(text) == "string" and text ~= "" then
              return { { text = text, hl = "Comment" } }
            end
            return { { text = "<anonymous>", hl = "Comment" } }
          end,
        },
      },
    },
  },
}
