-- 统一图标导出。所有数据源在 data/*.json，loader 负责读取并映射高亮组。
-- 唯一例外：diagnostics / kinds 直接手写 lua（hl 跟 colorscheme，不走 JSON）
--
-- 暴露形态：
--   icons.get(category, name)      → icon, hl, is_default  统一查询，对齐 MiniIcons.get()
--   icons.xxx                      → glyph string          扁平访问（ui + git + diagnostics 合并）
--   icons.ns.ui / .git / ...       → { key = glyph }       按命名空间取 glyph
--   icons.raw.ui / .git / ...      → { key = {glyph,hl} }  原始 entry（需要 hl 时用）
--   icons.files / .directories / … → { name = {glyph,hl} } 传给 MiniIcons.setup() 的字典

---@alias VVIconCategory 'file'|'directory'|'extension'|'filetype'|'ui'|'git'|'diagnostics'|'kinds'

---@class VVIcons
---@field get fun(category: VVIconCategory, name: string): string?, string?, boolean
---@field ns { ui: table<string,string>, git: table<string,string>, diagnostics: table<string,string>, kinds: table<string,string> }
---@field raw { ui: table<string,VVIconEntry>, git: table<string,VVIconEntry>, diagnostics: table<string,VVIconEntry>, kinds: table<string,VVIconEntry> }
---@field files table<string, VVIconEntry>
---@field directories table<string, VVIconEntry>
---@field extensions table<string, VVIconEntry>
---@field filetypes table<string, VVIconEntry>
---@field [string] string

local L = require("vv-icons.loader")

local ui_raw          = L.load_dict("ui")
local git_raw         = L.load_dict("git")
local diagnostics_raw = require("vv-icons.diagnostics")
local kinds_raw       = require("vv-icons.kinds")

--- { key = { glyph, hl } }  →  { key = glyph }
---@param tbl table<string, VVIconEntry>
---@return table<string, string>
local function flatten(tbl)
  local out = {}
  for k, v in pairs(tbl) do
    out[k] = type(v) == "table" and v.glyph or v
  end
  return out
end

local ui          = flatten(ui_raw)
local git         = flatten(git_raw)
local diagnostics = flatten(diagnostics_raw)
local kinds       = flatten(kinds_raw)

---@type VVIcons
local M = {}

M.ns = {
  ui          = ui,
  git         = git,
  diagnostics = diagnostics,
  kinds       = kinds,
}

-- 扁平合并到 M：icons.git_modified → glyph string（ui + git + diagnostics 的 key 全部提升到顶层）
for _, tbl in ipairs({ ui, git, diagnostics }) do
  for k, v in pairs(tbl) do M[k] = v end
end

M.raw = {
  ui          = ui_raw,
  git         = git_raw,
  diagnostics = diagnostics_raw,
  kinds       = kinds_raw,
}

-- mini.icons 字典（原样 {glyph,hl} 结构）
M.files       = L.load_files("files")
M.directories = L.load_directories("directories")
M.extensions  = L.load_dict("extensions")
M.filetypes   = L.load_dict("filetypes")

local MI_CATEGORIES = { file = true, directory = true, extension = true, filetype = true }

--- 统一查询入口，返回值对齐 MiniIcons.get()
--- ui/git/diagnostics/kinds → 查 raw 表；file/directory/extension/filetype → 委托 MiniIcons（含大小写回退）
---@param category VVIconCategory
---@param name string
---@param opts? { open?: boolean, empty?: boolean }
---@return string? icon, string? hl, boolean is_default
function M.get(category, name, opts)
  local raw_tbl = M.raw[category]
  if raw_tbl then
    local entry = raw_tbl[name]
    if entry then
      local glyph = (opts and opts.open and entry.open_glyph) or entry.glyph
      return glyph, entry.hl, false
    end
    return nil, nil, true
  end

  if MI_CATEGORIES[category] then
    -- 目录状态逻辑
    if category == "directory" and opts then
      local entry = M.directories[name]
      if not entry and name:lower() ~= name then entry = M.directories[name:lower()] end

      -- 1. 空目录优先
      if opts.empty then
        local folder_empty = M.raw.ui.folder_empty
        if folder_empty then
          return folder_empty.glyph, (entry and entry.hl), false
        end
      end

      -- 2. 展开态逻辑
      if opts.open then
        if entry and entry.open_glyph then
          return entry.open_glyph, entry.hl, false
        end
        -- 如果是特定目录图标（如 test），不强制换成 folder_open
        if entry and entry.glyph then
          return entry.glyph, entry.hl, false
        end
        -- 全局展开 fallback
        local folder_open = M.raw.ui.folder_open
        if folder_open then
          -- 注意：这里 hl 返回 nil，让插件 fallback 到自己的 VVExplorerDir
          return folder_open.glyph, (entry and entry.hl), false
        end
      end
    end

    local mi = _G.MiniIcons
    if mi then
      local icon, hl, is_default = mi.get(category, name)
      if not is_default then return icon, hl, false end
      local lower = name:lower()
      if lower ~= name then
        icon, hl, is_default = mi.get(category, lower)
        if not is_default then return icon, hl, false end
      end
      return icon, hl, true
    end
  end

  return nil, nil, true
end

return M
