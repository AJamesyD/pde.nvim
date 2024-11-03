-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

-- HACK: Below used to force autocmd types to come into scope.
-- TODO: Modify lazydev.nvim to do this automatically
---@module 'lazyvim'

-- Show absolute line numbers in cmd mode only
autocmd({ "CmdlineEnter" }, {
  desc = "Absolute numbers in cmd mode",
  callback = function(event)
    local bufnr = event.buf
    local number = vim.api.nvim_get_option_value("number", { scope = "local" })
    local relativenumber = vim.api.nvim_get_option_value("relativenumber", { scope = "local" })

    vim.b[bufnr].prev_relativenumber = relativenumber
    if number and relativenumber then
      vim.opt_local.relativenumber = false
    end
  end,
})

autocmd({ "CmdlineLeave" }, {
  desc = "Relative numbers outside cmd mode",
  callback = function(event)
    local bufnr = event.buf
    local number = vim.api.nvim_get_option_value("number", { scope = "local" })
    local relativenumber = vim.api.nvim_get_option_value("relativenumber", { scope = "local" })

    local prev_relativenumber = vim.b[bufnr].prev_relativenumber
    -- if prev_relativenumber hasn't been set, default to true
    prev_relativenumber = prev_relativenumber or (type(prev_relativenumber) == "nil")
    if number and not relativenumber then
      vim.opt_local.relativenumber = prev_relativenumber
    end
  end,
})

autocmd({ "BufWinEnter" }, {
  desc = "Schedule unlisting of irrelevant buffers",
  group = augroup("irrelevant_file"),
  callback = function(event)
    local bufnr = event.buf
    local bufglobals = vim.b[bufnr]
    local bufopts = vim.bo[bufnr]
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local bufvalid = vim.api.nvim_buf_is_valid(bufnr)

    if not bufvalid then
      return
    elseif not bufopts.buflisted then
      -- Unlisted buffers are often used for mystical purposes we don't want to mess with
      return
    end

    bufglobals.is_relevant_file = false

    if MyUtils.is_relevant_file(bufname, bufnr) then
      bufglobals.is_relevant_file = true
      return
    end

    autocmd({ "BufWinLeave" }, {
      desc = "Unlist irrelevant buffer",
      buffer = bufnr,
      group = augroup("irrelevant_file"),
      callback = function()
        if vim.bo.modified then
          local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname(bufnr)), "&Yes\n&No\n&Cancel")
          if choice == 0 or choice == 3 then -- 0 for <Esc>/<C-c> and 3 for Cancel
            return
          end
          if choice == 1 then -- Yes
            vim.cmd.write()
          end
        end

        bufopts.buflisted = false
      end,
    })
  end,
})

-- FileType specific options
autocmd({ "FileType" }, {
  desc = "KDL opts",
  pattern = "kdl",
  callback = function()
    vim.opt_local.commentstring = "// %s"
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})

autocmd({ "FileType" }, {
  desc = "Mark text files",
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function(event)
    local bufnr = event.buf
    local bufglobals = vim.b[bufnr]
    bufglobals.is_text_file = true
  end,
})

autocmd({ "BufAdd" }, {
  desc = "Mark test files",
  callback = function(event)
    local bufnr = event.buf
    local bufglobals = vim.b[bufnr]
    local filename = vim.fn.expand("<afile>")
    if filename:match("tests/") or filename:match("test/") or filename:match("tst/") then
      bufglobals.is_test_file = true
    end
  end,
})
