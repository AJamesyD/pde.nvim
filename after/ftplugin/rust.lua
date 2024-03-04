local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set("n", "<leader>uD", function()
  local client = vim.lsp.get_clients({ name = "rust-analyzer" })[1]
  local settings = client.config.settings or {}

  vim.g.rust_clippy_pedantic = not vim.g.rust_clippy_pedantic
  if vim.g.rust_clippy_pedantic then
    settings["rust-analyzer"].check.extraArgs = {
      "--no-deps",
      "--",
      "-Wclippy::pedantic",
      "-Wclippy::nursery",
      "-Wclippy::cargo",
    }
    vim.notify("pedantic and nursery lints enabled")
  else
    settings["rust-analyzer"].check.extraArgs = {
      "--no-deps",
      "--",
      "-Wclippy::cargo",
    }
    vim.notify("pedantic and nursery lints disabled")
  end

  client.config.settings = settings
  client.notify("workspace/didChangeConfiguration", {
    settings = settings,
  })
  vim.cmd("RustAnalyzer restart")
end, { desc = "Toggle diagnostic level", buffer = bufnr })
