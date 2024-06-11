-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt
local g = vim.g
local app_name = vim.env.NVIM_APPNAME and vim.env.NVIM_APPNAME or "nvim"

-- Language lint levels
g.clippy_level = 0
g.pyright_level = 2

-- Other globals
g.codeium_enabled = true
g.minipairs_disable = true
g.lazyvim_python_lsp = "basedpyright"
g.bufferline_filter_enabled = true

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
  g.neovide_remember_window_size = true
  g.neovide_cursor_vfx_mode = "railgun"
  g.neovide_refresh_rate = 30
  g.neovide_no_idle = true
  opt.guifont = "BlexMono Nerd Font Mono:h20"
  -- opt.guifont = "IBM Plex Mono,Symbols Nerd Font,Symbols NFM:h22:e-subpixelantialiasing"
end

opt.autowrite = false
opt.clipboard = ""

opt.incsearch = true
opt.hlsearch = false

opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.cache/" .. app_name .. "/undo//"

function _G.foldtext()
  local ok = pcall(vim.treesitter.get_parser, vim.api.nvim_get_current_buf())
  local ret = ok and vim.treesitter.foldtext and vim.treesitter.foldtext()
  if not ret or type(ret) == "string" then
    ret = { { vim.api.nvim_buf_get_lines(0, vim.v.lnum - 1, vim.v.lnum, false)[1], {} } }
  end
  local num_lines = vim.v.foldend - vim.v.foldstart + 1
  table.insert(ret, { "  " .. num_lines })

  if not vim.treesitter.foldtext then
    return table.concat(
      vim.tbl_map(function(line)
        return line[1]
      end, ret),
      " "
    )
  end
  return ret
end

vim.opt.foldtext = "v:lua.foldtext()"

vim.opt.listchars = {
  eol = "󰌑",
  nbsp = "␣",
  trail = "·",
  precedes = "←",
  extends = "→",
  tab = "¬ ",
  conceal = "※",
}
