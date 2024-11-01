-- Many of the following utils are ~~plagiarized from~~ inspired by https://github.com/nvim-telescope/telescope.nvim

local Path = require("plenary.path")
local Process = require("lazy.manage.process")

---@param separator string
---@return table
function string:split(separator)
  local outResults = {}
  local theStart = 1
  local theSplitStart, theSplitEnd = string.find(self, separator, theStart)

  while theSplitStart do
    table.insert(outResults, string.sub(self, theStart, theSplitStart - 1))
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = string.find(self, separator, theStart)
  end

  table.insert(outResults, string.sub(self, theStart))
  return outResults
end

local M = {}
---@class reload_lsp_config_opts
--- Search criteria for active lsp
---@field client_filter vim.lsp.get_clients.Filter
--- Method used to update lsp setting. See the {settings} in |vim.lsp.Client|.
--- (default: leaves original settings)
---@field settings_updater? fun(settings: table): table|nil
--- Cmd or Lua function to restart lsp
--- (default: LspRestart)
---@field restart_cmd? string|fun()|nil

---@param opts reload_lsp_config_opts
---@return nil
function M.reload_lsp_setting(opts)
  local client_filter = opts.client_filter

  local settings_updater = opts.settings_updater or function(settings)
    return settings
  end

  --- Ensure restart_cmd is a function
  local restart_cmd = opts.restart_cmd
  if type(opts.restart_cmd) == "string" then
    restart_cmd = function()
      vim.cmd(opts.restart_cmd)
      vim.notify("LSP settings updated")
    end
  end
  restart_cmd = restart_cmd or function()
    vim.cmd("LspRestart")
    vim.notify("LSP settings updated")
  end

  local clients = vim.lsp.get_clients(client_filter)
  if not clients then
    vim.notify("No lsp client found", vim.log.levels.WARN)
  elseif #clients > 1 then
    vim.notify(">1 lsp clients found", vim.log.levels.WARN)
  end
  local client = clients[1]

  local settings = client.config.settings or {}
  client.config.settings = settings_updater(settings)
  client.notify("workspace/didChangeConfiguration", {
    settings = settings,
  })
  restart_cmd()
end

---@param full_file_name string
---@param bufnr number
---@return boolean
function M.is_relevant_file(full_file_name, bufnr)
  -- XXX: This method does not yet work well
  if not full_file_name or full_file_name == "" then
    vim.b[bufnr].is_relevant_file = true
    return true
  end

  local cwd = LazyVim.root.cwd()
  local root = LazyVim.root.get({ normalize = true, buf = bufnr })

  local cwd_in_root = root:find(cwd, 1, true) == 1
  local root_in_cwd = cwd:find(root, 1, true) == 1
  if not cwd_in_root and not root_in_cwd then
    -- root and cwd are not related
    vim.b[bufnr].is_relevant_file = false
    return false
  end

  local find_command = (function()
    if 1 == vim.fn.executable("fd") then
      -- Allow symlinks so we can still find nix managed files
      -- Exclude .git/ since we want hidden files but .git/ isn't typically in .gitignore
      return { "fd", "--type", "file", "--type", "symlink", "--hidden", "--exclude", ".git/", "--color", "never" }
    end
  end)()

  if not find_command then
    vim.notify("You need to install fd", vim.log.levels.ERROR)
    vim.b[bufnr].is_relevant_file = true
    return true
  end

  -- Include --full-path so that we don't accidentally match if the same filename is found elsewhere under root,
  -- E.g. Cargo.toml in a multi-package workspace
  vim.list_extend(find_command, { "--full-path", "--base-directory", root, full_file_name })

  local out, exit_code = Process.exec(find_command)
  if exit_code ~= 0 then
    vim.notify("fd command failed. Output: " .. table.concat(out, "\n"), vim.log.levels.ERROR)
    vim.b[bufnr].is_relevant_file = true
    return true
  end

  if #out <= 1 then
    vim.b[bufnr].is_relevant_file = false
    return false
  elseif #out == 2 then
    -- Includes newline
    vim.b[bufnr].is_relevant_file = true
    return true
  elseif #out > 2 then
    -- This can happen when opening a dir in NetRW
    vim.b[bufnr].is_relevant_file = true
    return true
  end
  vim.b[bufnr].is_relevant_file = false
  return false
end

---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts? vim.keymap.set.Opts
M.map = function(mode, lhs, rhs, opts)
  opts = opts or {}

  opts.remap = false
  if opts.remap then
    opts.remap = opts.remap
  end

  opts.silent = opts.silent ~= false

  vim.keymap.set(mode, lhs, rhs, opts)
end

---@param toggle lazyvim.Toggle
function M.wrap(toggle)
  return setmetatable(toggle, {
    __call = function()
      toggle.set(not toggle.get())
      return toggle.get()
    end,
  })
end

---@param lhs string
---@param toggle lazyvim.Toggle
---@param silent? boolean
M.map_toggle = function(lhs, toggle, silent)
  local t
  if silent then
    t = M.wrap(toggle)
  else
    t = LazyVim.toggle.wrap(toggle)
  end
  M.map("n", lhs, function()
    t()
  end, { desc = "Toggle " .. toggle.name })
  LazyVim.toggle.wk(lhs, toggle)
end

M.is_amazon = function()
  return os.getenv("USER") == "angaidan"
end

return M
