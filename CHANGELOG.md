# Changelog

## [0.1.0] - 2026-07-13

### Added

- **状态感应图标**：`icons.get()` 接口支持 `opts.open` 和 `opts.empty` 参数，允许根据目录的展开和是否为空返回不同图标
- **Snacks.nvim 风格文件夹**：在 `ui.json` 中定义了符合 `snacks.nvim` 视觉习惯的 `folder` (󰉋), `folder_open` (󰝰), `folder_empty` (󰉖) 图标
- **目录展开态配置**：`directories.json` 支持 `open_glyph` 字段（如 `src` 展开显示 `󰝰`）

### Fixed

- `icons.kinds` 此前永远是 `nil`（扁平合并循环漏掉 kinds），导致 blink.cmp 的 `kind_icons` 取不到自定义图标；现整表挂到 `M.kinds`（与 `M.ns.kinds` 同引用），不扁平展开避免 Pascal 键污染顶层
- `load_files` / `load_directories` 对单条畸形 JSON（缺 `match` 或 brace 不匹配）不再向上抛穿打挂整个 `require('vv-icons')`：缺 `match` 先 guard、`expand_braces` 用 pcall 兜底，失败仅 `vim.notify` 告警并跳过该条，与 `read_json` 容错层级一致
- `load_directories` 不再对 ≤3 字符及 `ss` 结尾目录名错误追加 `s`：把跳过条件抽成前置 guard，消除 `csss`/`ioss`/`k8ss`/`srcs`/`scsss`/`cypresss` 等永不命中的垃圾键，合法单复数变体不受影响

### Internal

- **Loader 升级**：`loader.lua` 现已支持从 JSON 中解析 `open_glyph` 属性
- **颜色回退优化**：当目录仅命中全局展开/收起 fallback 且未定义特定语义色时，返回 `hl = nil` 以便调用方回退到自有高亮
