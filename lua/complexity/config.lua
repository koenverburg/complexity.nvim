local M = {}

M.supported_filetypes = {
  -- "javascript",
  -- "javascriptreact",
  "typescript",
  "typescriptreact",
  "tsx",
}

M.signs = {
  error = { highlightGroup = "DiagnosticSignError", icon = "" },
  warn  = { highlightGroup = "DiagnosticSignWarn",  icon = "" },
  hint  = { highlightGroup = "DiagnosticSignHint",  icon = "" },
  info  = { highlightGroup = "DiagnosticSignInfo",  icon = "" },
}

M.namespace = vim.api.nvim_create_namespace("complexity")

return M
