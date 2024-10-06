local bufnr = vim.api.nvim_get_current_buf()
local function settings_updater(settings)
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

  vim.notify(message)

  settings["rust-analyzer"].check.extraArgs = extra_args
  return settings
end

vim.keymap.set("n", "<leader>uD", function()
  local client_filter = {
    bufnr = bufnr,
    name = "rust-analyzer",
  }
  MyUtils.reload_lsp_setting({
    client_filter = client_filter,
    settings_updater = settings_updater,
    restart_cmd = "RustAnalyzer restart",
  })
end, { desc = "Toggle diagnostic level", buffer = bufnr })
