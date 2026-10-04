-- 每个子进程的场景辅助，不参与测试收集。
local plugin_root = vim.env.VV_TEST_REPO

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

Smoke = { require_from_copy_with_bad_files = require_from_copy_with_bad_files }
