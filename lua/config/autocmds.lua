-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Show absolute line numbers in cmd mode only
autocmd("CmdlineEnter", {
  desc = "Absolute numbers in cmd mode",
  group = augroup("cmdline_enter", { clear = true }),
  callback = function()
    vim.opt.relativenumber = false
  end,
})

autocmd("CmdlineLeave", {
  desc = "Relative numbers outside cmd mode",
  group = augroup("cmdline_leave", { clear = true }),
  callback = function()
    if vim.wo.number then
      vim.opt.relativenumber = true
    end
  end,
})

--- Filetype specific options
-- autocmd("FileType", {
--   desc = "Python opts",
--   pattern = "python",
--   group = augroup("python_opts", { clear = true }),
--   callback = function()
--     vim.opt_local...
--   end,
-- })
