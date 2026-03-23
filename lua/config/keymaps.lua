-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = require("util").map
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

-- quit/session: disabled, user doesn't use nvim session persistence
del("n", "<leader>qq")

-- windows: <leader>wd and <leader>wm are real keymaps in LazyVim keymaps.lua.
-- <leader>w-/w| are which-key proxy entries, not real keymaps (can't del).
-- Swap bindings moved to <C-w>HJKL in ui.lua.
del("n", "<leader>wd")
del("n", "<leader>wm")

-- PRUNED 2026-03-22: palette-safe, remove after 4 weeks
-- Only del() bindings from LazyVim's config/keymaps.lua (loaded before us)
del("n", "<leader>ft") -- terminal (root)
del("n", "<leader>fT") -- terminal (cwd)
del("n", "<leader>xl") -- location list
del("n", "<leader>gl") -- lazygit log (use lazygit directly)
del("n", "<leader>gL") -- lazygit log (cwd)
-- <leader>xL, <leader>n: defined in plugin specs,
-- disabled via { key, false } in their respective plugin specs in editor.lua

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

-- cut/copy/paste
map({ "n", "v" }, "<C-y>", '"+y', { desc = "Yank to clip" })
map({ "n", "v" }, "<C-p>", '"+p', { desc = "Paste from clip" })
map({ "n", "v" }, "$", "g_", { desc = "which_key_ignore", remap = true })
map({ "n", "v" }, "c", '"_c', { desc = "which_key_ignore" })
map({ "n" }, "x", '"_x', { desc = "which_key_ignore" })
map({ "x" }, "p", '"_p', { desc = "which_key_ignore" })

-- Misc
-- https://github.com/shell-pool/shpool/issues/71#issuecomment-2632396805
map({ "n", "v", "i", "t" }, "<C-a><C-q>", function()
  vim.cmd("!shpool detach")
end)

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
