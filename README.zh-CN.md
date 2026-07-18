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

无 `setup` / 无 `opts`，纯数据 + 纯函数 loader，加载即用。

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

Lua 侧映射到 `MiniIcons{Color}` 高亮组（由 colorscheme 提供具体色值），shell 侧映射到 256 色 ANSI。
