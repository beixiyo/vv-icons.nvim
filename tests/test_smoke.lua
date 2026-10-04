-- 真实场景在独立子进程中执行；收集阶段仅注册具名用例。
local H = dofile(vim.env.VV_TEST_REPO .. '/tests/helpers.lua')
local T, child = H.new_set({ setup = 'fixture_smoke.lua' })

T["真实 JSON 图标加载可供补全种类消费者使用"] = function()
  child.lua_func(function()
    do
    local require_from_copy_with_bad_files = Smoke.require_from_copy_with_bad_files
      package.loaded['vv-icons.loader'] = nil
      local loader = require('vv-icons.loader')
      local ui = loader.load_dict('ui')
      assert(type(ui) == 'table', '返回值不是表')
      assert(next(ui) ~= nil, 'ui 字典为空')
    end
    do
    local require_from_copy_with_bad_files = Smoke.require_from_copy_with_bad_files
      package.loaded['vv-icons'] = nil
      package.loaded['vv-icons.loader'] = nil
      package.loaded['vv-icons.diagnostics'] = nil
      package.loaded['vv-icons.kinds'] = nil
      local ok, icons = pcall(require, 'vv-icons')
      assert(ok, 'require 失败: ' .. tostring(icons))
      assert(type(icons) == 'table', '返回值不是表')
    end
    do
    local require_from_copy_with_bad_files = Smoke.require_from_copy_with_bad_files
      for _, m in ipairs({ 'vv-icons', 'vv-icons.loader', 'vv-icons.diagnostics', 'vv-icons.kinds' }) do
        package.loaded[m] = nil
      end
      local icons = require('vv-icons')
      assert(type(icons.kinds) == 'table', 'icons.kinds 不是表（#63 未修复时为 nil）')
      assert(icons.kinds == icons.ns.kinds, 'icons.kinds 应与 icons.ns.kinds 同引用')
      assert(next(icons.kinds) ~= nil, 'icons.kinds 为空')
    end
    do
    local require_from_copy_with_bad_files = Smoke.require_from_copy_with_bad_files
      local icons = require('vv-icons')
      assert(type(icons.kinds.Function) == 'string' and icons.kinds.Function ~= '', 'Function 键不是非空字符串')
      assert(type(icons.kinds.Method) == 'string', 'Method 键不是字符串')
      assert(type(icons.kinds.Class) == 'string', 'Class 键不是字符串')
    end
    do
    local require_from_copy_with_bad_files = Smoke.require_from_copy_with_bad_files
      local icons = require('vv-icons')
      assert(icons.Function == nil, '顶层 icons.Function 应为 nil（kinds 不该扁平展开污染顶层）')
      assert(icons.Method == nil, '顶层 icons.Method 应为 nil')
    end
  end)
end

T["不存在的 JSON 安全降级为空字典"] = function()
  child.lua_func(function()
    do
    local require_from_copy_with_bad_files = Smoke.require_from_copy_with_bad_files
      package.loaded['vv-icons.loader'] = nil
      local loader = require('vv-icons.loader')
      local result = loader.load_dict('__nonexistent_test_file__')
      assert(type(result) == 'table', '返回值不是表')
      assert(next(result) == nil, '应返回空表')
    end
  end)
end

T["目录图标变体保留有效词形并拒绝垃圾派生键"] = function()
  child.lua_func(function()
    do
    local require_from_copy_with_bad_files = Smoke.require_from_copy_with_bad_files
      package.loaded['vv-icons.loader'] = nil
      local d = require('vv-icons.loader').load_directories('directories')
      for _, k in ipairs({ 'csss', 'ioss', 'k8ss', 'srcs', 'scsss', 'cypresss', 'uis' }) do
        assert(d[k] == nil, '不该生成垃圾键: ' .. k)
      end
    end
    do
    local require_from_copy_with_bad_files = Smoke.require_from_copy_with_bad_files
      local d = require('vv-icons.loader').load_directories('directories')
      for _, k in ipairs({ 'chart', 'upload', 'download', 'sources', 'event', 'task' }) do
        assert(d[k] ~= nil, '合法变体丢失: ' .. k)
      end
      for _, k in ipairs({ 'css', 'ios', 'k8s', 'src', 'scss', 'cypress', 'ui' }) do
        assert(d[k] ~= nil, '原始键丢失: ' .. k)
      end
    end
  end)
end

T["缺少匹配字段的图标条目不阻断其余数据"] = function()
  child.lua_func(function()
    do
    local require_from_copy_with_bad_files = Smoke.require_from_copy_with_bad_files
      local ok, icons = require_from_copy_with_bad_files('{ "glyph": "x", "color": "red" }')
      assert(ok, '缺 match 应被跳过而非抛错: ' .. tostring(icons))
      assert(type(icons.files) == 'table' and next(icons.files) ~= nil, '其余 files 图标应正常加载')
    end
  end)
end

T["损坏括号匹配不阻断其余图标数据"] = function()
  child.lua_func(function()
    do
    local require_from_copy_with_bad_files = Smoke.require_from_copy_with_bad_files
      local ok, icons = require_from_copy_with_bad_files('{ "match": "foo{bar", "glyph": "x", "color": "red" }')
      assert(ok, '未闭合括号应被跳过而非抛错: ' .. tostring(icons))
      assert(type(icons.directories) == 'table' and next(icons.directories) ~= nil, '其余 directories 图标应正常加载')
    end
  end)
end

return T
