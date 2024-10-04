-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
local g = vim.g
local app_name = vim.env.NVIM_APPNAME and vim.env.NVIM_APPNAME or "nvim"

-- LazyVim globals
g.lazyvim_statuscolumn = {
  -- folds_open = true, -- A little too busy
  -- folds_githl = true, -- Only catches if first line of fold is diff
}
g.lazyvim_python_lsp = "basedpyright"

-- Plugin globals
g.mkdp_port = 8999 -- markdown-preview.nvim requires "LocalForward 8999 [127.0.0.1]:8999"

-- Custom globals
g.codeium_enabled = false
g.minipairs_disable = true
g.bufferline_filter_enabled = true
g.flash_enabled = false
g.clippy_level = 0
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
opt.mouse = ""

-- TODO: Experiment with nvim-ufo
-- function _G.foldtext()
--   local ok = pcall(vim.treesitter.get_parser, vim.api.nvim_get_current_buf())
--   local ret = ok and vim.treesitter.foldtext and vim.treesitter.foldtext()
--   if not ret or type(ret) == "string" then
--     ret = { { vim.api.nvim_buf_get_lines(0, vim.v.lnum - 1, vim.v.lnum, false)[1], {} } }
--   end
--   local num_lines = vim.v.foldend - vim.v.foldstart + 1
--   table.insert(ret, { "  " .. num_lines })
--
--   if not vim.treesitter.foldtext then
--     return table.concat(
--       vim.tbl_map(function(line)
--         return line[1]
--       end, ret),
--       " "
--     )
--   end
--   return ret
-- end
-- vim.opt.foldtext = "v:lua.foldtext()"

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
