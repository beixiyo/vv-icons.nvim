# Changelog

## 0.1.0 - 2026-07-13

### Added

- `icons.get()` 新增 `opts.open` / `opts.empty` 状态感应，支持 `directories.json` 的 `open_glyph` 展开态配置

### Changed

- 目录仅命中通用展开 / 收起图标且无专属颜色时返回 `hl = nil`，供调用方回退到自有高亮

### Fixed

- 补齐 `icons.kinds` 导出，与 `icons.ns.kinds` 共用图标表，恢复 blink.cmp 自定义 kind 图标
- 文件 / 目录 JSON 中缺少 `match` 或 brace 不匹配的条目仅告警并跳过，不再导致整个模块加载失败
- 不再为 ≤3 字符或以 `ss` 结尾的目录名错误追加 `s`，合法单复数变体不受影响
