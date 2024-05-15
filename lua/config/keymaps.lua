-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
local function map(mode, lhs, rhs, opts)
  -- set default value if not specify
  if opts.noremap == nil then
    opts.noremap = true
  end
  if opts.silent == nil then
    opts.silent = true
  end

  vim.keymap.set(mode, lhs, rhs, opts)
end

local del = vim.keymap.del

--
del("n", "<leader>`")
del("n", "<leader>ur")
del("n", "<leader>K")
del("n", "<leader>l")
del("n", "<leader>fn")

del("n", "]e")
del("n", "[e")
del("n", "]w")
del("n", "[w")

del("n", "<leader>ui")

del("n", "<leader>L")

del("n", "<leader>ft")
del("n", "<leader>fT")
del("n", "<c-/>")
del("n", "<c-_>")

del("t", "<esc><esc>")
del("t", "<C-h>")
del("t", "<C-j>")
del("t", "<C-k>")
del("t", "<C-l>")
del("t", "<C-/>")
del("t", "<c-_>")

del("n", "<leader><tab>l")
del("n", "<leader><tab>f")
del("n", "<leader><tab><tab>")
del("n", "<leader><tab>]")
del("n", "<leader><tab>d")
del("n", "<leader><tab>[")

-- Add any additional keymaps here
-- better movement
map("n", "<C-u>", "<C-u>zz", {})
map("n", "<C-d>", "<C-d>zz", {})
map("n", "<C-b>", "<C-b>zz", {})
map("n", "<C-f>", "<C-f>zz", {})
map("n", "<C-o>", "<C-o>zz", {})
map("n", "<C-i>", "<C-i>zz", {})

-- cut/copy/paste
map({ "n" }, "x", '"_x', {})
map({ "x" }, "p", '"_dP', {})
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to clip" })
map({ "n" }, "<leader>Y", '"+y$', { desc = "Yank to clip (EOL)" })
map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from clip" })
map({ "n", "v" }, "<leader>P", '"+P', { desc = "Paste from clip" })
map({ "n", "v" }, "<leader>D", '"_d', { desc = "Delete to void" })

-- folds
map({ "n", "v" }, "<C-.>", "za", { desc = "Toggle fold" })

-- code
map({ "n", "v" }, "<leader>cc", function()
  vim.g.codeium_enabled = not vim.g.codeium_enabled
end, { desc = "Toggle Codeium" })
