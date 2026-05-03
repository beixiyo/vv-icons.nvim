-- 统一图标导出。所有数据源在 data/*.json，loader 负责读取并映射高亮组。
-- 唯一例外：diagnostics 用 DiagnosticError/Warn/Hint/Info 高亮组（跟 colorscheme），保留手写 lua
--
-- 暴露形态：
--   1. 扁平 glyph：icons.find_file / icons.git_status / icons.diagnostics_error
--   2. 命名空间 glyph 表：icons.ns.ui / icons.ns.git / icons.ns.diagnostics / icons.ns.kinds
--   3. 原始 {glyph,hl} 表：icons.raw.<name>
--   4. mini.icons setup 直接吃的字典：icons.files / icons.directories / icons.extensions / icons.filetypes

---@class VVIcons
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

-- 扁平合并；放最后，让字符串覆盖任何同名命名空间
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

return M
