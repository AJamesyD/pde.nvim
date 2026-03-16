local bufnr = vim.api.nvim_get_current_buf()
local lsp_name = "basedpyright"
local modes = { [0] = "off", "basic", "standard", "strict", "all" }

vim.keymap.set("n", "<leader>cD", function()
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = lsp_name })[1]
  if not client then
    vim.notify("No " .. lsp_name .. " client attached", vim.log.levels.WARN)
    return
  end

  vim.g.pyright_level = ((vim.g.pyright_level or 1) + 1) % #modes
  local mode = modes[vim.g.pyright_level]

  client.config.settings.basedpyright.analysis.typeCheckingMode = mode
  vim.notify(lsp_name .. " typeCheckingMode: " .. mode)
  client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
  vim.cmd("LspRestart")
end, { desc = "Cycle Diagnostic Level", buffer = bufnr })
