-- Cycle diagnostic strictness for whichever Python type checker is attached.
-- basedpyright: typeCheckingMode (off/basic/standard/strict/all)
-- ty: diagnosticMode (off/openFilesOnly/workspace)

local bufnr = vim.api.nvim_get_current_buf()

local bp_modes = { [0] = "off", "basic", "standard", "strict", "all" }
local ty_modes = { "off", "openFilesOnly", "workspace" }

vim.keymap.set("n", "<leader>cD", function()
  local ty = vim.lsp.get_clients({ bufnr = bufnr, name = "ty" })[1]
  if ty then
    vim.g.ty_diag_level = ((vim.g.ty_diag_level or 1) % #ty_modes) + 1
    local mode = ty_modes[vim.g.ty_diag_level]
    ty.config.settings = vim.tbl_deep_extend("force", ty.config.settings or {}, {
      ty = { diagnosticMode = mode },
    })
    vim.notify("ty diagnosticMode: " .. mode)
    ty.notify("workspace/didChangeConfiguration", { settings = ty.config.settings })
    return
  end

  local bp = vim.lsp.get_clients({ bufnr = bufnr, name = "basedpyright" })[1]
  if bp then
    vim.g.pyright_level = ((vim.g.pyright_level or 1) + 1) % #bp_modes
    local mode = bp_modes[vim.g.pyright_level]
    bp.config.settings.basedpyright.analysis.typeCheckingMode = mode
    vim.notify("basedpyright typeCheckingMode: " .. mode)
    bp.notify("workspace/didChangeConfiguration", { settings = bp.config.settings })
    vim.cmd("LspRestart")
    return
  end

  vim.notify("No Python type checker attached", vim.log.levels.WARN)
end, { desc = "Cycle Diagnostic Level", buffer = bufnr })
