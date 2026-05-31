-- vv-icons.nvim 变更验证脚本
-- 用法:
--   cd vv-icons.nvim && nvim --headless -u NONE -l tests/test_smoke.lua
--   或在 nvim 内:  :luafile vv-icons.nvim/tests/test_smoke.lua

-- 让 require('vv-icons.xxx') 在 -u NONE 下也能工作
local this = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p')
local plugin_root = vim.fn.fnamemodify(this, ':h:h')
package.path = plugin_root .. '/lua/?.lua;' .. plugin_root .. '/lua/?/init.lua;' .. package.path

local passed = 0
local failed = 0

local function test(name, fn)
  local ok, err = pcall(fn)
  if ok then
    passed = passed + 1
    print('  PASS: ' .. name)
  else
    failed = failed + 1
    print('  FAIL: ' .. name .. ' -> ' .. tostring(err))
  end
end

print('\n=== vv-icons.nvim 变更验证 ===\n')

-- 测试 1: DATA_DIR 动态路径定位
print('[1] DATA_DIR 动态路径定位')

test('loader.lua 使用 debug.getinfo 定位 data/ 目录', function()
  -- 读取 loader.lua 源码，确认不含硬编码 stdpath
  local loader_path = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h')
    .. '/../lua/vv-icons/loader.lua'
  local content = table.concat(vim.fn.readfile(loader_path), '\n')
  assert(
    not content:find("stdpath('config').-vendors/vv%-icons"),
    '仍包含硬编码 stdpath 路径'
  )
  assert(
    content:find("debug.getinfo"),
    '未使用 debug.getinfo 动态定位'
  )
end)

test('data/ 目录存在且包含 JSON 文件', function()
  local data_dir = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':h')
    .. '/../lua/vv-icons/data/'
  assert(vim.fn.isdirectory(data_dir) == 1, 'data/ 目录不存在: ' .. data_dir)
  local json_files = vim.fn.glob(data_dir .. '*.json', false, true)
  assert(#json_files > 0, 'data/ 中无 JSON 文件')
end)

test('require("vv-icons.loader") 正常加载', function()
  package.loaded['vv-icons.loader'] = nil
  local loader = require('vv-icons.loader')
  assert(type(loader.load_dict) == 'function', 'load_dict 不是函数')
  assert(type(loader.load_files) == 'function', 'load_files 不是函数')
end)

test('load_dict 能正常读取 ui.json', function()
  package.loaded['vv-icons.loader'] = nil
  local loader = require('vv-icons.loader')
  local ui = loader.load_dict('ui')
  assert(type(ui) == 'table', '返回值不是 table')
  assert(next(ui) ~= nil, 'ui 字典为空')
end)

-- 测试 2: JSON 读取失败降级
print('\n[2] JSON 读取失败降级')

test('读取不存在的 JSON 文件返回空表（不抛异常）', function()
  package.loaded['vv-icons.loader'] = nil
  local loader = require('vv-icons.loader')
  local result = loader.load_dict('__nonexistent_test_file__')
  assert(type(result) == 'table', '返回值不是 table')
  assert(next(result) == nil, '应返回空表')
end)

test('require("vv-icons") 整体不崩溃', function()
  package.loaded['vv-icons'] = nil
  package.loaded['vv-icons.loader'] = nil
  package.loaded['vv-icons.diagnostics'] = nil
  package.loaded['vv-icons.kinds'] = nil
  local ok, icons = pcall(require, 'vv-icons')
  assert(ok, 'require 失败: ' .. tostring(icons))
  assert(type(icons) == 'table', '返回值不是 table')
end)

-- 测试 3: #63 kinds 顶层暴露（blink kind_icons）
print('\n[3] #63 icons.kinds 顶层可取')

test('require("vv-icons").kinds 是有效表且与 ns.kinds 同引用', function()
  for _, m in ipairs({ 'vv-icons', 'vv-icons.loader', 'vv-icons.diagnostics', 'vv-icons.kinds' }) do
    package.loaded[m] = nil
  end
  local icons = require('vv-icons')
  assert(type(icons.kinds) == 'table', 'icons.kinds 不是 table（#63 未修复时为 nil）')
  assert(icons.kinds == icons.ns.kinds, 'icons.kinds 应与 icons.ns.kinds 同引用')
  assert(next(icons.kinds) ~= nil, 'icons.kinds 为空表')
end)

test('kinds 的值是 glyph 字符串（blink kind_icons 需要 name→glyph）', function()
  local icons = require('vv-icons')
  assert(type(icons.kinds.Function) == 'string' and icons.kinds.Function ~= '', 'Function 不是非空 glyph 字符串')
  assert(type(icons.kinds.Method) == 'string', 'Method 不是字符串')
  assert(type(icons.kinds.Class) == 'string', 'Class 不是字符串')
end)

test('kinds 未污染顶层（Pascal 键不应扁平展开到 M）', function()
  local icons = require('vv-icons')
  assert(icons.Function == nil, '顶层 icons.Function 应为 nil（kinds 不该扁平展开污染顶层）')
  assert(icons.Method == nil, '顶层 icons.Method 应为 nil')
end)

-- 测试 4: #65 load_directories 单复数 guard
print('\n[4] #65 load_directories 不生成垃圾单复数键')

test('≤3 字符 / ss 结尾不生成垃圾变体键', function()
  package.loaded['vv-icons.loader'] = nil
  local d = require('vv-icons.loader').load_directories('directories')
  for _, k in ipairs({ 'csss', 'ioss', 'k8ss', 'srcs', 'scsss', 'cypresss', 'uis' }) do
    assert(d[k] == nil, '不该生成垃圾键: ' .. k)
  end
end)

test('合法单复数变体仍保留，原始键不丢失', function()
  local d = require('vv-icons.loader').load_directories('directories')
  for _, k in ipairs({ 'chart', 'upload', 'download', 'sources', 'event', 'task' }) do
    assert(d[k] ~= nil, '合法变体丢失: ' .. k)
  end
  for _, k in ipairs({ 'css', 'ios', 'k8s', 'src', 'scss', 'cypress', 'ui' }) do
    assert(d[k] ~= nil, '原始键丢失: ' .. k)
  end
end)

-- 测试 5: #64 单条畸形 JSON 不阻断 require
print('\n[5] #64 畸形 entry 不炸 require')

-- 拷贝到临时目录注入畸形 files.json 条目，require 仍应成功（其余图标正常）
local function require_from_copy_with_bad_files(bad_entry)
  local tmp = vim.fn.tempname()
  vim.fn.mkdir(tmp .. '/lua', 'p')
  local rc = vim.fn.system({ 'cp', '-r', plugin_root .. '/lua/vv-icons', tmp .. '/lua/vv-icons' })
  if vim.v.shell_error ~= 0 then error('cp 失败: ' .. tostring(rc)) end

  local fjson = tmp .. '/lua/vv-icons/data/files.json'
  local content = table.concat(vim.fn.readfile(fjson), '\n')
  content = content:gsub('%[', '[\n  ' .. bad_entry .. ',', 1)
  vim.fn.writefile(vim.split(content, '\n'), fjson)

  local mods = { 'vv-icons', 'vv-icons.loader', 'vv-icons.diagnostics', 'vv-icons.kinds' }
  for _, m in ipairs(mods) do package.loaded[m] = nil end
  local saved = package.path
  package.path = tmp .. '/lua/?.lua;' .. tmp .. '/lua/?/init.lua;' .. package.path
  local ok, icons = pcall(require, 'vv-icons')
  package.path = saved
  for _, m in ipairs(mods) do package.loaded[m] = nil end
  return ok, icons
end

test('缺 match 的条目不阻断 require（其余图标正常）', function()
  local ok, icons = require_from_copy_with_bad_files('{ "glyph": "x", "color": "red" }')
  assert(ok, '缺 match 应被跳过而非抛错: ' .. tostring(icons))
  assert(type(icons.files) == 'table' and next(icons.files) ~= nil, '其余 files 图标应正常加载')
end)

test('括号不匹配的 match 不阻断 require', function()
  local ok, icons = require_from_copy_with_bad_files('{ "match": "foo{bar", "glyph": "x", "color": "red" }')
  assert(ok, '未闭合 brace 应被跳过而非抛错: ' .. tostring(icons))
  assert(type(icons.directories) == 'table' and next(icons.directories) ~= nil, '其余 directories 图标应正常加载')
end)

-- 汇总
print(string.format(
  '\n=== 结果: %d 通过, %d 失败 ===\n',
  passed, failed
))

if failed > 0 then
  vim.cmd('cq 1')
end
