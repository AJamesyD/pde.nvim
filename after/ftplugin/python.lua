-- ty diagnostic mode cycling
-- ty has no typeCheckingMode (unlike basedpyright). The closest equivalent is
-- diagnosticMode: "off" / "openFilesOnly" / "workspace"
-- See: https://docs.astral.sh/ty/reference/editor-settings/

local bufnr = vim.api.nvim_get_current_buf()
local modes = { "off", "openFilesOnly", "workspace" }

vim.keymap.set("n", "<leader>cD", function()
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = "ty" })[1]
  if not client then
    vim.notify("No ty client attached", vim.log.levels.WARN)
    return
  end

  vim.g.ty_diag_level = ((vim.g.ty_diag_level or 1) % #modes) + 1
  local mode = modes[vim.g.ty_diag_level]

  client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, {
    ty = { diagnosticMode = mode },
  })
  vim.notify("ty diagnosticMode: " .. mode)
  client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
end, { desc = "Cycle Diagnostic Mode", buffer = bufnr })
