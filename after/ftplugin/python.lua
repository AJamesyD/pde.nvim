local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set("n", "<leader>uD", function()
  local client = vim.lsp.get_active_clients({ name = "basedpyright" })[1]
  local settings = client.config.settings or {}

  vim.g.pyright_level = (vim.g.pyright_level + 1) % 5
  local type_checking_mode = ""
  if vim.g.pyright_level == 0 then
    type_checking_mode = "off"
  elseif vim.g.pyright_level == 1 then
    type_checking_mode = "basic"
  elseif vim.g.pyright_level == 2 then
    type_checking_mode = "standard"
  elseif vim.g.pyright_level == 3 then
    type_checking_mode = "strict"
  elseif vim.g.pyright_level == 4 then
    type_checking_mode = "all"
  end
  settings.basedpyright.analysis.typeCheckingMode = type_checking_mode
  vim.notify("pyright typeCheckingMode: " .. type_checking_mode)

  client.config.settings = settings
  client.notify("workspace/didChangeConfiguration", {
    settings = settings,
  })
  vim.cmd("LspRestart")
end, { desc = "Toggle diagnostic level", buffer = bufnr })
