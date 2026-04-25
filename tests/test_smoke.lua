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

-- 汇总
print(string.format(
  '\n=== 结果: %d 通过, %d 失败 ===\n',
  passed, failed
))

if failed > 0 then
  vim.cmd('cq 1')
end
