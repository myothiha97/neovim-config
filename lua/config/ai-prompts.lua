local M = {}

local function copy_prompt(prompt, title)
  vim.fn.setreg("+", prompt)
  vim.notify(title .. " copied to clipboard", vim.log.levels.INFO, { title = "AI Prompt" })
end

local function current_buffer_path()
  local path = vim.api.nvim_buf_get_name(0)
  return path ~= "" and vim.fn.fnamemodify(path, ":.") or "[No Name]"
end

local function current_file_context()
  local relative = current_buffer_path()
  local line = vim.api.nvim_win_get_cursor(0)[1]

  local target_types = {
    class_declaration = true,
    class_definition = true,
    arrow_function = true,
    function_declaration = true,
    function_definition = true,
    function_expression = true,
    function_item = true,
    function_statement = true,
    lexical_declaration = true,
    method_declaration = true,
    method_definition = true,
    variable_declaration = true,
  }

  local symbol
  local ok, node = pcall(vim.treesitter.get_node)
  while ok and node do
    if target_types[node:type()] then
      local row = node:start()
      local text = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
      symbol = text and vim.trim(text) or nil
      break
    end
    node = node:parent()
  end

  if symbol and #symbol > 120 then
    symbol = symbol:sub(1, 117) .. "..."
  end

  return relative, line, symbol
end

local function visual_selection()
  local live_mode = vim.fn.mode()
  local in_visual = live_mode == "v" or live_mode == "V" or live_mode == "\22"
  local vmode = in_visual and live_mode or vim.fn.visualmode()
  local start_pos = in_visual and vim.fn.getpos("v") or vim.fn.getpos("'<")
  local end_pos = in_visual and vim.fn.getpos(".") or vim.fn.getpos("'>")
  local start_line, start_col = start_pos[2], start_pos[3]
  local end_line, end_col = end_pos[2], end_pos[3]

  if start_line == 0 or end_line == 0 then
    return "", 0, 0
  end

  if start_line > end_line or (start_line == end_line and start_col > end_col) then
    start_line, end_line = end_line, start_line
    start_col, end_col = end_col, start_col
  end

  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  if #lines == 0 then
    return "", start_line, end_line
  end

  if vmode == "\22" then
    local left_col = math.min(start_col, end_col)
    local right_col = math.max(start_col, end_col)
    for i, line in ipairs(lines) do
      lines[i] = line:sub(left_col, right_col)
    end
  elseif vmode ~= "V" then
    lines[#lines] = lines[#lines]:sub(1, end_col)
    lines[1] = lines[1]:sub(start_col)
  end

  -- Leave visual mode so the toast isn't masked by the visual-mode indicator.
  if in_visual then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  end

  return table.concat(lines, "\n"), start_line, end_line
end

local prompts = {
  commit = {
    action = "Generate a high-quality git commit message for the current changes and perform git commit",
    focus = "Use Conventional Commits. Keep the subject short, imperative, and specific. If the changes mix or unrelated work, recommend splitting them into separate commits but only if the changes are very unrleated  if not summarize the changes to one single commit. Do not invent behavior that is not visible in the diff.",
  },
  codebase_analysis = {
    action = "Analyze this codebase as a senior engineer.",
    focus = table.concat({
      "Analyze the repository architecture, maintainability, performance risks, Neovim/LazyVim configuration structure, plugin boundaries, language support, and testing or verification gaps.",
      "",
      "Return:",
      "1. Highest-impact findings first, with file references.",
      "2. Concrete improvement recommendations.",
      "3. Any risky assumptions or missing context.",
      "4. A short phased plan for cleanup or refactoring.",
    }, "\n"),
  },
  explain_current_file = {
    action = "Explain the codebase inside this file and the role of this file in the codebase.",
    focus = "Focus on purpose, main responsibilities, important dependencies, data flow, and how this file connects to nearby modules. Keep it concise, concrete, and reference specific lines or symbols.",
  },
  explain_current_symbol = {
    action = "Explain the specific function, class, or expressions near my cursor.If the cursor is inside the fucntion or class , explain that function or class as well as its relationship to the surrounding code.",
    focus = "Focus on purpose, inputs and outputs, control flow, dependencies, edge cases, and why this code exists. Keep it concise, concrete, and reference specific lines or symbols.",
  },
  explain_selection = {
    action = "Explain the selected code or text.",
    focus = "Focus on meaning, key ideas, important details, dependencies or unfamiliar terms, and anything non-obvious. Also if the selection is the code block rather than just normal text then explain additionally about its role and  how this particular selection was used or fit in the file. Keep it concise and concrete but can be more detailed if necessary",
  },
  refactor = {
    action = "Refactor this code to improve readability, maintainability, and simplicity without changing behavior.",
    focus = "Keep the existing style and architecture. Avoid unnecessary abstractions. Explain the key changes and any tradeoffs.",
  },
  review_changes = {
    action = "Review the current local changes before commit.",
    focus = table.concat({
      "Take a code-review stance. Prioritize bugs, regressions, performance risks, maintainability issues, and missing verification. Be concrete and cite file paths and line numbers where possible. If no serious issues are found, say that clearly and list any residual risks.",
      "",
      "Also do a light architecture review: check whether the changes fit the existing config structure, naming, keymap conventions, and LazyVim plugin boundaries.",
      "",
      "Return findings first, ordered by severity. Then include open questions and a brief summary.",
    }, "\n"),
  },
}

-- Join: action, optional context block, optional focus, optional trailing block. Blank line between each.
local function render(template, context, trailing)
  local parts = { template.action }
  local function append(block)
    if not block or #block == 0 then
      return
    end
    table.insert(parts, "")
    for _, line in ipairs(block) do
      table.insert(parts, line)
    end
  end
  append(context)
  if template.focus then
    table.insert(parts, "")
    table.insert(parts, template.focus)
  end
  append(trailing)
  return table.concat(parts, "\n")
end

function M.commit_prompt()
  return render(prompts.commit)
end

function M.codebase_analysis_prompt()
  return render(prompts.codebase_analysis)
end

function M.explain_current_context_prompt()
  local file, line = current_file_context()
  return render(prompts.explain_current_file, {
    "Target file: " .. file,
    "Cursor line: " .. line,
  })
end

function M.explain_current_symbol_prompt()
  local file, line, symbol = current_file_context()
  local context = { "Target: " .. file .. ":" .. line }
  if symbol then
    table.insert(context, "Nearest symbol: " .. symbol)
  end
  return render(prompts.explain_current_symbol, context)
end

function M.explain_selection_prompt(selection, start_line, end_line)
  selection = selection or ""
  start_line = start_line or 0
  end_line = end_line or start_line

  return render(
    prompts.explain_selection,
    { "Source: " .. current_buffer_path() .. ":" .. start_line .. "-" .. end_line },
    { "Selected content:", selection }
  )
end

function M.refactor_prompt()
  return render(prompts.refactor, { "Target file: " .. current_buffer_path() })
end

function M.review_changes_prompt()
  return render(prompts.review_changes)
end

-- Each entry pairs a prompt builder with its user command, keymap, and descriptions.
-- `with_range` marks the one prompt that consumes a visual selection or :range.
local registry = {
  {
    key = "commit",
    title = "Commit message prompt",
    command = "AICopyCommitPrompt",
    command_desc = "Copy an AI prompt for generating a commit message",
    keymap = "<leader>acc",
    keymap_mode = "n",
    keymap_desc = "AI Prompt: Commit Message",
  },
  {
    key = "codebase_analysis",
    title = "Codebase analysis prompt",
    command = "AICopyCodebaseAnalysisPrompt",
    command_desc = "Copy an AI prompt for codebase analysis",
    keymap = "<leader>aca",
    keymap_mode = "n",
    keymap_desc = "AI Prompt: Analyze Codebase",
  },
  {
    key = "explain_current_context",
    title = "Current file explanation prompt",
    command = "AICopyExplainCurrentContextPrompt",
    command_desc = "Copy an AI prompt for explaining the current file",
    keymap = "<leader>ace",
    keymap_mode = "n",
    keymap_desc = "AI Prompt: Explain Current File",
  },
  {
    key = "explain_current_symbol",
    title = "Current symbol explanation prompt",
    command = "AICopyExplainCurrentSymbolPrompt",
    command_desc = "Copy an AI prompt for explaining the nearest symbol",
    keymap = "<leader>acs",
    keymap_mode = "n",
    keymap_desc = "AI Prompt: Explain Current Symbol",
  },
  {
    key = "explain_selection",
    title = "Selection explanation prompt",
    command = "AICopyExplainSelectionPrompt",
    command_desc = "Copy an AI prompt for explaining selected code or text",
    keymap = "<leader>acd",
    keymap_mode = "x",
    keymap_desc = "AI Prompt: Explain Selection",
    with_range = true,
  },
  {
    key = "refactor",
    title = "Refactor prompt",
    command = "AICopyRefactorPrompt",
    command_desc = "Copy an AI prompt for refactoring code",
    keymap = "<leader>acf",
    keymap_mode = "n",
    keymap_desc = "AI Prompt: Refactor Code",
  },
  {
    key = "review_changes",
    title = "Review changes prompt",
    command = "AICopyReviewChangesPrompt",
    command_desc = "Copy an AI prompt for reviewing local changes before commit",
    keymap = "<leader>acr",
    keymap_mode = "n",
    keymap_desc = "AI Prompt: Review Changes",
  },
}

for _, entry in ipairs(registry) do
  if entry.with_range then
    M["copy_" .. entry.key .. "_prompt"] = function(opts)
      local selection, start_line, end_line
      if opts and opts.range and opts.range > 0 then
        start_line = opts.line1
        end_line = opts.line2
        selection = table.concat(vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false), "\n")
      else
        selection, start_line, end_line = visual_selection()
      end
      copy_prompt(M.explain_selection_prompt(selection, start_line, end_line), entry.title)
    end
  else
    local builder = M[entry.key .. "_prompt"]
    M["copy_" .. entry.key .. "_prompt"] = function()
      copy_prompt(builder(), entry.title)
    end
  end
end

function M.setup()
  for _, entry in ipairs(registry) do
    local fn = M["copy_" .. entry.key .. "_prompt"]
    vim.api.nvim_create_user_command(entry.command, fn, {
      desc = entry.command_desc,
      range = entry.with_range or nil,
    })
    vim.keymap.set(entry.keymap_mode, entry.keymap, fn, { desc = entry.keymap_desc })
  end

  local ok, wk = pcall(require, "which-key")
  if ok then
    wk.add({
      { "<leader>ac", group = "AI prompts" },
    })
  end
end

return M
