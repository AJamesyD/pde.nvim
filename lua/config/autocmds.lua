-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Show absolute line numbers in cmd mode only
autocmd("CmdlineEnter", {
  desc = "Absolute numbers in cmd mode",
  callback = function(event)
    local number = vim.api.nvim_get_option_value("number", { scope = "local" })
    local relativenumber = vim.api.nvim_get_option_value("relativenumber", { scope = "local" })

    if number and relativenumber then
      vim.opt_local.relativenumber = false
    end
  end,
})

autocmd("CmdlineLeave", {
  desc = "Relative numbers outside cmd mode",
  callback = function()
    local number = vim.api.nvim_get_option_value("number", { scope = "local" })
    local relativenumber = vim.api.nvim_get_option_value("relativenumber", { scope = "local" })

    if number and not relativenumber then
      vim.opt_local.relativenumber = true
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

    -- Use project root since this may be executing from any buffer in a project with different cwd
    local root = LazyVim.root.get({ normalize = true, buf = bufnr })
    -- TODO: not sure if path_expand required, just mindlessly copying telescope
    root = require("telescope.utils").path_expand(root)

    if MyUtils.is_relevant_file(bufname, root) then
      bufglobals.is_relevant_file = true
      return
    end

    bufglobals.is_relevant_file = false

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

--- Filetype specific options
autocmd("FileType", {
  desc = "KDL opts",
  pattern = "kdl",
  callback = function()
    vim.opt_local.commentstring = "// %s"
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})

autocmd("FileType", {
  desc = "Mark text files for faster identification in bufferline",
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function(event)
    local bufnr = event.buf
    local bufglobals = vim.b[bufnr]
    bufglobals.is_text_file = true
  end,
})
