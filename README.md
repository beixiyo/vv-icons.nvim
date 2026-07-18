<div align="center">
  <h1>vv-icons.nvim</h1>
  <p>English | <a href="./README.zh-CN.md">中文</a></p>
  <p>Want my Neovim config? See <a href="https://github.com/beixiyo/dotfiles">dotfiles</a></p>
  <em>A shared icon library stored as JSON, allowing Neovim and shell tools to consume the same data</em>
  <p>
    <img src="https://img.shields.io/badge/Neovim-0.10+-57A143?style=flat-square&logo=neovim&logoColor=white" alt="Requires Neovim 0.10+" />
    <img src="https://img.shields.io/badge/Lua-2C2D72?style=flat-square&logo=lua&logoColor=white" alt="Lua" />
    <img src="https://img.shields.io/badge/zero_deps-✓-2ea44f?style=flat-square" alt="Zero Dependencies" />
  </p>
</div>

---

## Installation

```lua
{
  'beixiyo/vv-icons.nvim',
  lazy = false,
  priority = 1000, -- Must be available when other plugins require('vv-icons') during startup
}
```

There is no `setup` function or `opts` table. The plugin is a pure data and function loader that is ready immediately after loading.

## Data files

| File | Format | Description |
|------|--------|-------------|
| `data/files.json` | List: `{ match, glyph, color }[]` | Matches filenames with globs, including brace expansion |
| `data/directories.json` | List: `{ match, glyph, color }[]` | Directory icons |
| `data/extensions.json` | Map | Icons by extension |
| `data/filetypes.json` | Map | Icons by filetype |
| `data/git.json` | Map | Git status icons |
| `data/ui.json` | Map | General UI icons |

## Lua API

```lua
local icons = require('vv-icons')

-- Flat glyph strings
icons.find_file

-- Namespaces
icons.ns.ui
icons.ns.git
icons.ns.kinds    -- LSP kind icons

-- Raw { glyph, hl } tables
icons.raw.ui

-- Dictionaries accepted directly by mini.icons
icons.files
icons.directories
icons.extensions
icons.filetypes
```

## Typical consumers

```lua
-- Feed the dictionaries to mini.icons
require('mini.icons').setup({
  file      = require('vv-icons').files,
  directory = require('vv-icons').directories,
  extension = require('vv-icons').extensions,
  filetype  = require('vv-icons').filetypes,
})

-- Kind icons for blink.cmp or nvim-cmp
local kinds = require('vv-icons').ns.kinds
```

## Optional colors

`green` / `yellow` / `red` / `blue` / `cyan` / `magenta` / `orange` / `purple` / `grey` / `white`

On the Lua side, colors map to `MiniIcons{Color}` highlight groups whose concrete values are supplied by the colorscheme. Shell consumers map them to the 256-color ANSI palette.
