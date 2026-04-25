# vv-icons.nvim

共享图标库：图标数据存在 JSON 里，**Neovim 和 shell 工具（zsh / bun fzf 等）可共用同一份数据**

## 安装

lazy.nvim：

```lua
{
  'beixiyo/vv-icons.nvim',
  lazy = false,
  priority = 1000,    -- 其他插件启动期 require('vv-icons') 时它需要先就位
}
```

## 目录结构

```
vv-icons.nvim/
├── README.md
└── lua/vv-icons/
    ├── init.lua          # facade：ns / raw / 扁平 + mini.icons 字典
    ├── loader.lua        # JSON 读取（动态路径 + 降级保护） + color → MiniIcons* 高亮映射 + glob brace 展开
    ├── diagnostics.lua   # DiagnosticError/Warn/Hint/Info（手写，不走 JSON 因为 hl 组固定）
    ├── kinds.lua         # LSP kind 图标（手写）
    └── data/
        ├── files.json        # 列表型 + glob：`{ match, glyph, color }[]`
        ├── directories.json  # 字典型：`{ name: { glyph?, color? } }`
        ├── extensions.json   # 字典型
        ├── filetypes.json    # 字典型
        ├── git.json          # 字典型（status 图标）
        └── ui.json           # 字典型（通用 UI 图标）
```

## JSON 条目格式

**字典型**（directories / extensions / filetypes / git / ui）：

```jsonc
{
  "charts":  { "glyph": "", "color": "green" },  // 完整
  "src":     { "color": "purple" },               // 仅改色，glyph 走 mini.icons 默认
  "scripts": { "glyph": "" }                     // 仅改 glyph，色走默认
}
```

**列表型**（files，支持 glob brace）：

```jsonc
[
  { "match": "{package,package-lock}.json", "glyph": "", "color": "red" },
  { "match": ".env{,.local,.development}",  "glyph": "", "color": "yellow" }
]
```

`match` 用 `expandBraces` 展开成多个字面量 key（实现见 [loader.lua](lua/vv-icons/loader.lua) 的 `expand_braces`）

## 可选色值

`green / yellow / red / blue / cyan / magenta / orange / purple / grey / white`

Lua 侧映射到 `MiniIcons{Green,Yellow,Red,Blue,Cyan,Purple,Orange,Grey,Azure}` 高亮组（由 colorscheme 提供具体色值）。Bun 侧映射到 256 色 ANSI（orange/purple 升为一等公民）

## Lua 引用

```lua
local icons = require('vv-icons')

icons.find_file              -- 扁平 glyph 字符串
icons.kinds                  -- 不暴露在扁平面，用 icons.ns.kinds
icons.ns.ui / ns.git / ...   -- 命名空间
icons.raw.ui / raw.git / ... -- 原始 {glyph, hl} 表
icons.files                  -- mini.icons 能直接吃的字典
icons.directories
icons.extensions
icons.filetypes
```

**典型消费**：

- 把 `icons.{files,directories,extensions,filetypes}` 灌给 mini.icons：`require('mini.icons').setup({ files = require('vv-icons').files, ... })`
- 把 `icons.ns.kinds` 灌给 blink.cmp / nvim-cmp 的 kind 图标
- spec / keymap 的 `desc` 字段直接用扁平 glyph 作前缀

## 路径定位

Lua 侧使用 `debug.getinfo` 动态获取 `loader.lua` 所在目录，自动推导 `data/` 路径。无论插件安装在 `vendors/`、`lazy/`、`packer/`、`mini.deps` 还是其他任意位置都能正确加载 JSON 数据，**无需硬编码路径**。

## 在 shell / Bun 侧消费

`data/*.json` 是平台无关的 JSON，shell 侧可以直接读取。例如 fzf 列表染色脚本（TS / Bun / Python 都可以），把仓库 clone 到本地后指向 `<repo>/lua/vv-icons/data/` 即可

## 加载顺序

参考"安装"段：用 `priority = 1000 + lazy = false`，让 vv-icons 在其他 require 它的插件之前 ready

## 不做什么

- **没有 setup / state**：纯数据 + 少量纯函数 loader
- **不代理到 mini.icons**：mini.icons 是 vv-icons 的消费者而非依赖
- **不做语义色→Hex**：具体色值交给 colorscheme（Lua）或 shell 终端（Bun）

## Testing

Smoke test (zero deps, runs in `-u NONE`):

```bash
nvim --headless -u NONE -l tests/test_smoke.lua
```

Expected: trailing line `X passed, 0 failed`.
