-- File outline — the IDE "Structure" pane (WebStorm Alt+7 / VS Code Outline).
--
-- Reuses trouble.nvim's `symbols` mode (already installed via LazyVim): no new plugin, and
-- nothing runs on the scroll/keypress hot path — the panel only works while it's open and
-- Trouble throttles its own updates. Safe for big files.
--
-- Toggle with <leader>cs. The ONLY display override is making the followed-symbol highlight
-- visible (your themes set the global CursorLine bg to NONE, which hides Trouble's marker).
--
-- Filtering: the outline has THREE detail levels, cycled by pressing `a` inside the panel:
--   1. STRUCTURE (default) — only functions, methods, classes and React components. No data
--      members at all, so the outline reads as pure structure.
--   2. + MEMBERS     — level 1 plus fields, properties and enum members (object/class shape),
--      but NOT loose local variables/constants.
--   3. ALL           — everything the LSP reports, unfiltered (adds local variables/constants).
-- `a` steps 1 → 2 → 3 → 1. (Members/variables are opt-in because vtsls reports every piece of
-- component state/props as Field/Variable, which buries the actual structure.)

-- Level 1: structural symbols only — callables + type/containers. Package is dropped on
-- purpose (file/package declaration + lua_ls control-flow blocks: never a useful entry).
local STRUCTURE_KINDS = {
  Class = true,
  Constructor = true,
  Enum = true,
  Function = true,
  Interface = true,
  Method = true,
  Module = true,
  Namespace = true,
  Struct = true,
  Trait = true,
}

-- Level 2 adds these on top of STRUCTURE_KINDS: object/class members (the shape of a type),
-- but deliberately NOT Variable/Constant — loose locals only appear at level 3.
local MEMBER_KINDS = {
  EnumMember = true,
  Field = true,
  Property = true,
}

-- The PascalCase-Variable/Constant "React component" heuristic is JS/TS-specific: only there
-- do arrow-function components get reported as Variable. Gating it to these filetypes stops
-- e.g. Go's exported (PascalCase) package vars/consts from leaking into the structure view.
local COMPONENT_FILETYPES = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
}

-- Current detail level (1/2/3); cycled by `a`, read by the symbols `filter` on every refresh.
local level = 1
local LEVEL_LABEL = {
  [1] = "structure (functions / classes / components)",
  [2] = "+ fields & properties",
  [3] = "all symbols (incl. variables)",
}

-- Remove the quickfix row(s) under the cursor (or visual selection) from the ACTUAL
-- quickfix list, not just Trouble's in-memory tree. Trouble's built-in `dd`/`delete`
-- only filters its own tree (view/tree.lua: node:delete()), so the entry returns the
-- moment the list is re-read on reopen. We prune the live list + persisted state, then
-- refresh — which re-fetches the now-smaller qflist source (view/section.lua: refresh).
local function remove_from_qflist(view)
  local targets = {}
  local function collect(node)
    local item = node.item
    -- Leaf rows carry the entry; filename group headers don't — recurse into them so a
    -- `dd` on a header removes all of that file's entries too.
    if item and (not node.children or #node.children == 0) then
      targets[#targets + 1] = {
        bufnr = item.buf,
        filename = item.filename,
        lnum = item.pos and item.pos[1] or nil,
        text = item.text,
      }
    end
    for _, child in ipairs(node.children or {}) do
      collect(child)
    end
  end

  for _, node in ipairs(view:selection()) do
    collect(node)
  end

  require("config.quickfix-persistence").remove(targets)
  view:refresh()
end

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
        -- Default level 1 (structure only). `a` cycles the detail level; see the top comment.
        filter = function(items)
          if level >= 3 then
            return items
          end
          return vim.tbl_filter(function(item)
            if STRUCTURE_KINDS[item.kind] then
              return true
            end
            if level >= 2 and MEMBER_KINDS[item.kind] then
              return true
            end
            -- React components are reported as Variable/Constant by vtsls (arrow functions),
            -- but are conventionally PascalCase — keep those at levels 1 & 2 so components
            -- always show alongside functions/classes, not only in the full view. JS/TS only
            -- (see COMPONENT_FILETYPES) so other languages' PascalCase data isn't pulled in.
            if
              COMPONENT_FILETYPES[vim.bo[item.buf or 0].filetype]
              and (item.kind == "Variable" or item.kind == "Constant")
            then
              local name = item.symbol and item.symbol.name
              return type(name) == "string" and name:match("^%u") ~= nil
            end
            return false
          end, items)
        end,
        keys = {
          a = {
            desc = "Outline: cycle detail level (structure / +members / all)",
            action = function(view)
              level = level % 3 + 1
              view:refresh()
              vim.notify("Outline: " .. LEVEL_LABEL[level], vim.log.levels.INFO)
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
      -- Quickfix list (you use it as code pins, harpoon-style). Rebind delete so it
      -- removes the entry from the real list + persisted state, not just the tree.
      qflist = {
        keys = {
          dd = {
            desc = "Remove from quickfix (live + persisted)",
            action = remove_from_qflist,
          },
          d = {
            mode = "v",
            desc = "Remove from quickfix (live + persisted)",
            action = remove_from_qflist,
          },
        },
      },
    },
  },
}
