-- 诊断图标
---@type table<string, VVIconEntry>
local M = {
  diagnostics       = { glyph = '', hl = 'MiniIconsOrange' },
  diagnostics_error = { glyph = '󰅙', hl = 'DiagnosticError' },
  diagnostics_warn  = { glyph = '', hl = 'DiagnosticWarn' },
  diagnostics_hint  = { glyph = '', hl = 'DiagnosticHint' },
  diagnostics_info  = { glyph = '', hl = 'DiagnosticInfo' },
}

return M
