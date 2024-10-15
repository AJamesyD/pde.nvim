-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
local g = vim.g
local app_name = vim.env.NVIM_APPNAME and vim.env.NVIM_APPNAME or "nvim"

-- Override default LazyVim globals
g.bigfile_size = 512 * 1024 -- 0.5MB. Default is 1.5MB
g.lazyvim_statuscolumn = {
  -- folds_open = true, -- A little too busy
  -- folds_githl = true, -- Only catches if first line of fold is diff
}
g.lazyvim_python_lsp = "basedpyright"

-- Plugin globals
g.mkdp_port = 8999 -- markdown-preview.nvim requires "LocalForward 8999 [127.0.0.1]:8999"

-- Custom globals
g.clippy_level = 0
g.codeium_enabled = false
g.concerning_file_size = 100 * 1024 -- 100 KB
g.minipairs_disable = true
g.pyright_level = 2

g.amazon = false
if os.getenv("USER") == "angaidan" then
  g.amazon = true
end

-- Neovide Configuration
if g.neovide then
  g.neovide_padding_top = 0
  g.neovide_padding_bottom = 0
  g.neovide_padding_right = 0
  g.neovide_padding_left = 0

  -- g.neovide_window_blurred = true;
  -- g.neovide_floating_blur_amount_x = 2.0
  -- g.neovide_floating_blur_amount_y = 2.0
  -- g:neovide_transparency = 0.8

  g.neovide_cursor_smooth_blink = true
  g.neovide_cursor_vfx_mode = "railgun"
  g.neovide_refresh_rate = 60
  g.neovide_refresh_rate_idle = 30
  g.neovide_no_idle = true

  g.neovide_confirm_quit = true

  g.neovide_input_macos_option_key_is_meta = "both"
  opt.linespace = -3
end

-- Override default LazyVim options
opt.autowrite = false
opt.clipboard = ""
opt.mouse = "nv" -- Normal and visual

opt.scrolloff = 15

opt.listchars = {
  -- eol = "󰌑",
  nbsp = "␣",
  trail = "·",
  precedes = "←",
  extends = "→",
  tab = "¬ ",
  conceal = "※",
}

-- Custom options
opt.incsearch = true
opt.hlsearch = false

opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.cache/" .. app_name .. "/undo//"

opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,"
  .. "a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,"
  .. "sm:block-blinkwait175-blinkoff150-blinkon175"
