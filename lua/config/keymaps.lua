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
del("n", "<leader>uT")
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
map("n", "<C-u>", "<C-u>zz")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-b>", "<C-b>zz")
map("n", "<C-f>", "<C-f>zz")
map("n", "<C-o>", "<C-o>zz")
map("n", "<C-i>", "<C-i>zz")

-- Move lines up/down (default is A-j/A-k)
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move Down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move Up" })

-- cut/copy/paste
map({ "n", "v" }, "$", "g_", { desc = "Paste from clip", remap = true })
map({ "n" }, "x", '"_x')
map({ "x" }, "p", '"_dP')
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clip" })
map({ "n" }, "<leader>Y", '"+y$', { desc = "Yank to clip (EOL)" })
map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from clip" })
map({ "n", "v" }, "<leader>P", '"+P', { desc = "Paste from clip" })
