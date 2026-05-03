-- 图标共享数据源 loader：读取 data/*.json，语义色映射到 mini.icons hl 组
-- 消费方：`require('vv-icons.loader').load_dict('git')`
-- 数据目录：<plugin_root>/lua/vv-icons/data/*.json（与 zsh/bun 侧共用同一份 JSON）

---@class VVIconEntry
---@field glyph? string
---@field hl? string

---@class VVIconsLoader
local M = {}

-- 动态定位 data/ 目录：基于当前文件（loader.lua）的实际路径推导
-- 无论插件安装在 vendors/、lazy/、packer/ 还是其他位置都能正确找到
local DATA_DIR = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h') .. '/data/'

-- 语义色 → mini.icons 高亮组
local COLOR_TO_HL = {
  green   = 'MiniIconsGreen',
  yellow  = 'MiniIconsYellow',
  red     = 'MiniIconsRed',
  blue    = 'MiniIconsBlue',
  cyan    = 'MiniIconsCyan',
  magenta = 'MiniIconsPurple',
  orange  = 'MiniIconsOrange',
  purple  = 'MiniIconsPurple',
  grey    = 'MiniIconsGrey',
  white   = 'MiniIconsAzure',
}

---@param color string
---@return string hl
local function color_to_hl(color)
  return COLOR_TO_HL[color] or 'MiniIconsGrey'
end

--- 展开单层 brace：'a.{b,c}' → {'a.b', 'a.c'}；'.env{,.local}' → {'.env', '.env.local'}
--- 仅支持 `{a,b,c}` 字面量组，不支持 `*` / `?` / 嵌套
---@param pattern string
---@return string[]
function M.expand_braces(pattern)
  local open_i = pattern:find('{', 1, true)
  if not open_i then return { pattern } end

  local close_i, depth = nil, 1
  for i = open_i + 1, #pattern do
    local c = pattern:sub(i, i)
    if c == '{' then
      depth = depth + 1
    elseif c == '}' then
      depth = depth - 1
      if depth == 0 then
        close_i = i
        break
      end
    end
  end
  if not close_i then
    error("expand_braces: unmatched '{' in " .. pattern)
  end

  local prefix = pattern:sub(1, open_i - 1)
  local suffix = pattern:sub(close_i + 1)
  local body = pattern:sub(open_i + 1, close_i - 1)

  local alts = {}
  local buf, depth2 = {}, 0
  for i = 1, #body do
    local c = body:sub(i, i)
    if c == ',' and depth2 == 0 then
      table.insert(alts, table.concat(buf))
      buf = {}
    else
      if c == '{' then depth2 = depth2 + 1 end
      if c == '}' then depth2 = depth2 - 1 end
      table.insert(buf, c)
    end
  end
  table.insert(alts, table.concat(buf))

  local out = {}
  for _, alt in ipairs(alts) do
    for _, tail in ipairs(M.expand_braces(suffix)) do
      table.insert(out, prefix .. alt .. tail)
    end
  end
  return out
end

--- 读取并解析 JSON
--- 读取或解析失败时降级为空表，不会阻断 require('vv-icons')
---@param name string 文件名（不含 .json）
---@return table
local function read_json(name)
  local path = DATA_DIR .. name .. '.json'
  local ok_read, content = pcall(vim.fn.readfile, path)
  if not ok_read then
    vim.notify('[vv-icons] 无法读取 ' .. path, vim.log.levels.WARN)
    return {}
  end
  local ok_parse, data = pcall(vim.json.decode, table.concat(content, '\n'))
  if not ok_parse then
    vim.notify('[vv-icons] JSON 解析失败 ' .. path .. ': ' .. tostring(data), vim.log.levels.WARN)
    return {}
  end
  return data
end

--- 字典型 JSON → { key = { glyph?, hl? } }
--- 偏字段覆盖：JSON 里省略 glyph 只填 color → MiniIcons 保留默认 glyph 仅改色
--- 适用 git / ui / diagnostics / extensions / filetypes
---@param name string
---@return table<string, VVIconEntry>
function M.load_dict(name)
  local raw = read_json(name)
  local out = {}
  for key, entry in pairs(raw) do
    local v = {}
    if entry.glyph then v.glyph = entry.glyph end
    if entry.color then v.hl = color_to_hl(entry.color) end
    out[key] = v
  end
  return out
end

--- 列表型 JSON + glob 展开 → { [literal_name] = { glyph, hl } }
--- 命中顺序：后出现的同名条目会覆盖先出现的（列表顺序即优先级，列表头优先）
---@param name string
---@return table<string, VVIconEntry>
function M.load_files(name)
  local raw = read_json(name)
  local out = {}
  for i = #raw, 1, -1 do
    local entry = raw[i]
    local value = { glyph = entry.glyph, hl = color_to_hl(entry.color) }
    for _, literal in ipairs(M.expand_braces(entry.match)) do
      out[literal] = value
    end
  end
  return out
end

--- 目录专用：load_files + 自动生成单复数变体
--- 'test' 自动补 'tests'，'docs' 自动补 'doc'（已有则不覆盖）
---@param name string
---@return table<string, VVIconEntry>
function M.load_directories(name)
  local out = M.load_files(name)
  local extras = {}
  for key, value in pairs(out) do
    if key:sub(-1) == 's' and key:sub(-2) ~= 'ss' and #key > 3 then
      local singular = key:sub(1, -2)
      if not out[singular] then extras[singular] = value end
    else
      local plural = key .. 's'
      if not out[plural] then extras[plural] = value end
    end
  end
  for k, v in pairs(extras) do out[k] = v end
  return out
end

return M
