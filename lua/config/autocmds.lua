-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
local autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end
local util = require("util")

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

    if util.is_relevant_file(bufname, bufnr) then
      return
    end

    autocmd({ "BufWinLeave" }, {
      desc = "Unlist irrelevant buffer",
      once = true,
      buffer = bufnr,
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

autocmd("FileType", {
  desc = "Disable spell if treesitter inactive",
  callback = function(event)
    local bufnr = event.buf
    if not vim.bo[bufnr].buflisted then
      return
    end
    -- Treesitter highlight attaches after FileType; defer to let it initialize
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end
      if not vim.treesitter.highlighter.active[bufnr] then
        for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
          vim.wo[win].spell = false
        end
      end
    end)
  end,
})

if util.amazon.is_amazon_machine() then
  autocmd({ "FileType" }, {
    desc = "ion opts",
    pattern = "ion",
    callback = function(event)
      local bufnr = event.buf
      local bufglobals = vim.b[bufnr]
      local filepath = vim.api.nvim_buf_get_name(bufnr)

      local is_amazon_proj = util.amazon.amazon_root(filepath)

      if is_amazon_proj then
        bufglobals.autoformat = false
      end
    end,
  })

  autocmd("LspAttach", {
    desc = "Amazon project setup",
    callback = function(event)
      local bufnr = event.buf
      local filepath = vim.api.nvim_buf_get_name(bufnr)

      local is_brazil_proj = util.amazon.amazon_root(filepath, "brazil")

      if is_brazil_proj then
        -- Often want to disable autoformatting in Brazil projects
        vim.b[bufnr].autoformat = false
      end

      -- Load workspace folders from pre-existing .bemol/ws_root_folders.
      -- If bemol hasn't been run yet, this is a no-op.
      -- After running bemol externally, use :BemolRefresh to pick up folders.
      if util.amazon.is_bemol_proj(bufnr) then
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client then
          local root_dir = util.amazon.amazon_root(filepath)
          util.amazon.load_bemol_workspace_folders(client, root_dir)
        end
      end
    end,
  })

  vim.api.nvim_create_user_command("Bemol", function()
    util.amazon.bemol_run()
  end, { desc = "Run bemol and refresh LSP workspace folders" })

  vim.api.nvim_create_user_command("BemolRefresh", function()
    util.amazon.bemol_refresh()
  end, { desc = "Re-read bemol workspace folders for all LSP clients" })
end
