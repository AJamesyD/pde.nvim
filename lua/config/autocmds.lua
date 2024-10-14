-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Show absolute line numbers in cmd mode only
autocmd("CmdlineEnter", {
  desc = "Absolute numbers in cmd mode",
  group = augroup("cmdline_enter"),
  callback = function(event)
    local buf = event.buf

    local number = vim.api.nvim_get_option_value("number", { scope = "local" })
    local relativenumber = vim.api.nvim_get_option_value("relativenumber", { scope = "local" })

    if number and relativenumber then
      vim.opt_local.relativenumber = false
    end
  end,
})

autocmd("CmdlineLeave", {
  desc = "Relative numbers outside cmd mode",
  group = augroup("cmdline_leave"),
  callback = function(event)
    local buf = event.buf

    local number = vim.api.nvim_get_option_value("number", { scope = "local" })
    local relativenumber = vim.api.nvim_get_option_value("relativenumber", { scope = "local" })

    if number and not relativenumber then
      vim.opt_local.relativenumber = true
    end
  end,
})

--- Filetype specific options
autocmd("FileType", {
  desc = "KDL opts",
  pattern = "kdl",
  group = augroup("kdl_opts"),
  callback = function()
    vim.opt_local.commentstring = "// %s"
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})
