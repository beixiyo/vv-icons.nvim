# Changelog

## [Unreleased]

### Added

- **状态感应图标**：`icons.get()` 接口支持 `opts.open` 和 `opts.empty` 参数，允许根据目录的展开和是否为空返回不同图标
- **Snacks.nvim 风格文件夹**：在 `ui.json` 中定义了符合 `snacks.nvim` 视觉习惯的 `folder` (󰉋), `folder_open` (󰝰), `folder_empty` (󰉖) 图标
- **目录展开态配置**：`directories.json` 支持 `open_glyph` 字段（如 `src` 展开显示 `󰝰`）

### Internal

- **Loader 升级**：`loader.lua` 现已支持从 JSON 中解析 `open_glyph` 属性
- **颜色回退优化**：当目录仅命中全局展开/收起 fallback 且未定义特定语义色时，返回 `hl = nil` 以便调用方回退到自有高亮
