-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
local g = vim.g
local app_name = vim.env.NVIM_APPNAME and vim.env.NVIM_APPNAME or "nvim"

-- Override default LazyVim globals
g.lazyvim_picker = "fzf"
g.lazyvim_prettier_needs_config = true
g.lazyvim_python_lsp = "basedpyright"
g.trouble_lualine = false
g.snacks_animate = false
if g.neovide then
  g.snacks_animate = true
end

-- Plugin globals
if vim.fn.exists("$SSH_CLIENT") ~= 0 then
  -- markdown-preview.nvim requires "LocalForward 8999 [127.0.0.1]:8999"
  g.mkdp_port = 8999
end

-- Custom globals
g.clippy_level = 0
g.concerning_file_size = 100 * 1024 -- 100 KB
g.minipairs_disable = true
g.pyright_level = 2

g.codeium_enabled = false

-- Neovide Configuration
if g.neovide then
  g.neovide_padding_top = 0
  g.neovide_padding_bottom = 0
  g.neovide_padding_right = 0
  g.neovide_padding_left = 0

  -- g.neovide_window_blurred = true;
  -- g:neovide_transparency = 0.8
  -- g.neovide_floating_blur_amount_x = 2.0
  -- g.neovide_floating_blur_amount_y = 2.0

  g.neovide_cursor_smooth_blink = true
  g.neovide_cursor_vfx_mode = "railgun"

  g.neovide_refresh_rate = 120
  g.neovide_refresh_rate_idle = 60
  g.neovide_no_idle = true

  -- TODO: Tune
  g.neovide_text_gamma = 0.0
  g.neovide_text_contrast = 1.0
  opt.linespace = -3

  g.neovide_confirm_quit = true
end

opt.spell = true
opt.spelloptions = "camel"
opt.spelllang = "en_us"

-- Override default LazyVim options
opt.autowrite = false
opt.clipboard = ""
opt.mouse = "nv" -- Normal and visual
opt.mousemoveevent = true

opt.scrolloff = 15
opt.sidescrolloff = 20

opt.softtabstop = -1 -- Will default to shiftwidth

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
