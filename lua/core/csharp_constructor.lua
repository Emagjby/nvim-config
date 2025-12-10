local M = {}

function M.generate_constructor()
  local api = vim.api
  local bufnr = api.nvim_get_current_buf()

  -- Find class name
  local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local class_name = nil

  for _, line in ipairs(lines) do
    local name = line:match("%s*class%s+([%w_]+)")
    if name then
      class_name = name
      break
    end
  end

  if not class_name then
    vim.notify("Couldnt find class declaration", vim.log.levels.WARN)
  end

  -- Collect fields
  local fields = {}
  for _, line in ipairs(lines) do
    -- 1️⃣  Try: private readonly <type> <name>;
    local type_, name = line:match("%s*private%s+readonly%s+([%w_%.<>%[%]]+)%s+([_%w]+)%s*;")

    -- 2️⃣  If no match → try: private <type> <name>;
    if not type_ then
      type_, name = line:match("%s*private%s+([%w_%.<>%[%]]+)%s+([_%w]+)%s*;")
    end

    -- 3️⃣  If matched, store it
    if type_ and name then
      table.insert(fields, { type = type_, name = name })
    end
  end

  if #fields == 0 then
    vim.notify("No matching private fields found.", vim.log.levels.INFO)
    return
  end

  -- Build constructor signature & body
  local params = {}
  local body = {}

  for _, f in ipairs(fields) do
    -- strip leading underscore for param name
    local paramName = f.name:gsub("^_", "")
    table.insert(params, f.type .. " " .. paramName)
    table.insert(body, ("        %s = %s;"):format(f.name, paramName))
  end

  local constructor_lines = {}

  table.insert(
    constructor_lines,
    ("    public %s(%s)"):format(class_name, table.concat(params, ", "))
  )
  table.insert(constructor_lines, "    {")
  vim.list_extend(constructor_lines, body)
  table.insert(constructor_lines, "    }")

  -- Insert at cursor line
  local row = api.nvim_win_get_cursor(0)[1]
  local insert_at = row
  api.nvim_buf_set_lines(bufnr, insert_at, insert_at, true, constructor_lines)
end

return M

