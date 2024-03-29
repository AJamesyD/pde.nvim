local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set("n", "<leader>uD", function()
  local client = vim.lsp.get_active_clients({ name = "rust-analyzer" })[1]
  local settings = client.config.settings or {}

  vim.g.clippy_level = (vim.g.clippy_level + 1) % 4
  local extra_args = {}
  local message = ""
  if vim.g.clippy_level == 0 then
    extra_args = {
      "--no-deps",
    }
    message = "clippy lints: default only"
  elseif vim.g.clippy_level == 1 then
    extra_args = {
      "--no-deps",
      "--",
      "-Wclippy::cargo",
    }
    message = "clippy lints: cargo, default"
  elseif vim.g.clippy_level == 2 then
    extra_args = {
      "--no-deps",
      "--",
      "-Wclippy::nursery",
      "-Wclippy::cargo",
    }
    message = "clippy lints: nursery, cargo, default"
  elseif vim.g.clippy_level == 3 then
    extra_args = {
      "--no-deps",
      "--",
      "-Wclippy::pedantic",
      "-Wclippy::nursery",
      "-Wclippy::cargo",
    }
    message = "clippy lints: pedantic, nursery, cargo, default"
  end
  settings["rust-analyzer"].check.extraArgs = extra_args
  vim.notify(message)

  client.config.settings = settings
  client.notify("workspace/didChangeConfiguration", {
    settings = settings,
  })
  vim.cmd("RustAnalyzer restart")
end, { desc = "Toggle diagnostic level", buffer = bufnr })
