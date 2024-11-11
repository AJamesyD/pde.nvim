-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = MyUtils.map
local del = vim.keymap.del

-- buffers
del("n", "<leader>`")

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
del("n", "<leader>ur")

-- lazy
del("n", "<leader>l")

-- new file
del("n", "<leader>fn")

-- toggle options
del("n", "<leader>ul")
del("n", "<leader>ub")

-- lazygit
-- TODO: Better git blame / <leader>gb
del("n", "<leader>gB")

-- highlights under cursor
del("n", "<leader>ui")
del("n", "<leader>uI")

-- LazyVim Changelog
del("n", "<leader>L")

-- tabs
del("n", "<leader><tab>l")
del("n", "<leader><tab>o")
del("n", "<leader><tab>f")
del("n", "<leader><tab><tab>")
del("n", "<leader><tab>]")
del("n", "<leader><tab>d")
del("n", "<leader><tab>[")

-- Add any additional keymaps here
-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zzzv'", { desc = "Next Search Result", expr = true })
map("n", "N", "'nN'[v:searchforward].'zzzv'", { desc = "Prev Search Result", expr = true })

-- better movement
map("n", "<C-u>", "<C-u>zz", { desc = "which_key_ignore" })
map("n", "<C-d>", "<C-d>zz", { desc = "which_key_ignore" })
map("n", "<C-b>", "<C-b>zz", { desc = "which_key_ignore" })
map("n", "<C-f>", "<C-f>zz", { desc = "which_key_ignore" })
map("n", "<C-o>", "<C-o>zz", { desc = "which_key_ignore" })
map("n", "<C-i>", "<C-i>zz", { desc = "which_key_ignore" })

-- buffers
if not vim.g.neovide then
  map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
  map("n", "<S-h>", "<cmd>bprev<cr>", { desc = "Prev Buffer" })
  map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
  map("n", "[b", "<cmd>bprev<cr>", { desc = "Prev Buffer" })
end

-- Move lines up/down (default is A-j/A-k)
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move Down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move Up" })

-- cut/copy/paste
map({ "n", "v" }, "$", "g_", { desc = "Paste from clip", remap = true })
map({ "n" }, "x", '"_x', { desc = "which_key_ignore" })
map({ "x" }, "p", '"_dP', { desc = "Paste over" })
map({ "n", "v" }, "<C-y>", '"+y', { desc = "Yank to clip" })
map({ "n", "v" }, "<C-p>", '"+p', { desc = "Paste from clip" })

-- toggle options. Overrides of LazyVim default keymaps must go in this file (why?)
require("snacks")
  .toggle({
    name = "Current Line Blame",
    get = function()
      return require("gitsigns.config").config.current_line_blame
    end,
    set = function(state)
      require("gitsigns.config").config.current_line_blame = state
      require("gitsigns.actions").refresh()
    end,
  })
  :map("<leader>ug")
require("snacks")
  .toggle({
    name = "Twilight",
    get = function()
      return require("twilight.view").enabled
    end,
    set = function(state)
      if state then
        require("twilight").enable()
      else
        require("twilight").disable()
      end
    end,
  })
  :map("<leader>uT")
