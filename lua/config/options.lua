-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
local g = vim.g
local app_name = vim.env.NVIM_APPNAME and vim.env.NVIM_APPNAME or "nvim"

g.amazon = false
if os.getenv("USER") == "angaidan" then
  g.amazon = true
end

-- Neovide Configuration
if g.neovide then
  g.neovide_transparency = 0.95
  g.transparency = 0.95
  g.neovide_floating_blur_amount_x = 5
  g.neovide_floating_blur_amount_y = 5
  g.neovide_remember_window_size = true
  g.neovide_cursor_vfx_mode = "railgun"
  opt.guifont = "VictorMono Nerd Font:h20"
end

opt.autowrite = false
opt.clipboard = ""

opt.scrolloff = 20
opt.sidescrolloff = 10

opt.breakindent = true
opt.copyindent = true

opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.cache/" .. app_name .. "/undo//"
