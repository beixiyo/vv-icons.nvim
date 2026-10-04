<div align="center">
  <h1>vv-icons.nvim</h1>
  <p><a href="./README.md">English</a> | 中文</p>
  <p>想要我的 Neovim 配置？查看 <a href="https://github.com/beixiyo/dotfiles">dotfiles</a></p>
  <em>共享图标库 — JSON 存储，Neovim 与 shell 工具共用同一份数据</em>
  <p>
  <img src="https://img.shields.io/badge/Neovim-0.10+-57A143?style=flat-square&logo=neovim&logoColor=white" alt="Requires Neovim 0.10+" />
  <img src="https://img.shields.io/badge/Lua-2C2D72?style=flat-square&logo=lua&logoColor=white" alt="Lua" />
  <img src="https://img.shields.io/badge/zero_deps-✓-2ea44f?style=flat-square" alt="Zero Dependencies" />
  </p>
</div>

---

## 安装

```lua
{
  'beixiyo/vv-icons.nvim',
  lazy = false,
  priority = 1000, -- 其他插件启动期 require('vv-icons') 时需要先就位
}
```

无 `setup` / 无 `opts`，纯数据 + 纯函数 loader，加载即用

## 数据文件

| 文件 | 格式 | 说明 |
|------|------|------|
| `data/files.json` | 列表型：`{ match, glyph, color }[]` | 按 glob（支持 brace 展开）匹配文件名 |
| `data/directories.json` | 列表型：`{ match, glyph, color }[]` | 目录图标 |
| `data/extensions.json` | 字典型 | 按扩展名 |
| `data/filetypes.json` | 字典型 | 按 filetype |
| `data/git.json` | 字典型 | git status 图标 |
| `data/ui.json` | 字典型 | 通用 UI 图标 |

## Lua 引用

```lua
local icons = require('vv-icons')

-- 扁平 glyph 字符串
icons.find_file

-- 命名空间
icons.ns.ui
icons.ns.git
icons.ns.kinds    -- LSP kind 图标

-- 原始 { glyph, hl } 表
icons.raw.ui

-- mini.icons 可直接消费的字典
icons.files
icons.directories
icons.extensions
icons.filetypes
```

## 典型消费

```lua
-- 灌给 mini.icons
require('mini.icons').setup({
  file      = require('vv-icons').files,
  directory = require('vv-icons').directories,
  extension = require('vv-icons').extensions,
  filetype  = require('vv-icons').filetypes,
})

-- 灌给 blink.cmp / nvim-cmp 的 kind 图标
local kinds = require('vv-icons').ns.kinds
```

## 可选色值

`green` / `yellow` / `red` / `blue` / `cyan` / `magenta` / `orange` / `purple` / `grey` / `white`

Lua 侧映射到 `MiniIcons{Color}` 高亮组（由 colorscheme 提供具体色值），shell 侧映射到 256 色 ANSI

## 开发测试

```sh
./tests/run.sh
./tests/run.sh '过滤词'
# 可选：指定 Neovim
NVIM_BIN=/path/to/nvim ./tests/run.sh
```

仅支持 Unix-like 系统；要求 Neovim 0.12+（建议使用 0.12 稳定版）、Git 和 POSIX shell
直接运行 `./tests/run.sh`，首次自动准备固定版本 vv-utils（`ed9b6ae`）与 mini.test 源码，
不要求兄弟仓库、个人 Neovim 配置或预装 parser。依赖保存在 `VV_TEST_DEPS_CACHE`，
默认 `$XDG_CACHE_HOME/nvim-test-deps` 或 `~/.cache/nvim-test-deps`；缓存齐全后可离线运行
`VV_UTILS` 可显式覆盖共享源码路径；`NVIM_BIN` 默认 `nvim`。过滤词按文件路径或中文用例名
做字面子串匹配，无匹配视为失败。入口不安装系统工具

每个具名 case 启动全新子 Neovim，不读取个人配置；cwd、HOME、XDG 与临时文件都位于独立 `/tmp`
父 hook 在断言失败时仍停止子进程并清理 fixture；scheduled 回调异常单独收集后断言
headless 状态验证不能替代真实终端的视觉和鼠标验证

测试读取真实 JSON，并向临时源码副本注入畸形条目
旧导出形状断言与实际补全消费者加载合并，不单独制造常量测试
