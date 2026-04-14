-- https://w.amazon.com/bin/view/Bemol#HPluginFeatures
local BEMOL_SUPPORTED_FTS = {
  "cpp",
  "c",
  "java",
  "kotlin",
  "python",
  "ruby",
  "javascript",
  "typescript",
}

local M = {}

---@param filename string
M.amazon_root = function(filename)
  local root_file = vim.fs.find("Config", { path = filename, type = "file", upward = true })[1]
  return vim.fs.dirname(root_file)
end

M.is_amazon_machine = function()
  return os.getenv("USER") == "angaidan"
end

---@param bufnr? integer
M.is_bemol_proj = function(bufnr)
  if type(bufnr) == "nil" then
    bufnr = 0
  end
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local filetype = vim.bo[bufnr].filetype
  return M.amazon_root(filepath) ~= nil and vim.tbl_contains(BEMOL_SUPPORTED_FTS, filetype)
end

-- Workspace folder management for bemol projects.
--
-- bemol generates .bemol/ws_root_folders listing package roots in a
-- multi-package workspace. LSP servers need these as workspace folders
-- to resolve cross-package imports and symbols.
--
-- Uses client:_add_workspace_folder (private Neovim API, stable since 0.9).
-- If this breaks in a future version, inline the logic: build {uri, name}
-- table, send workspace/didChangeWorkspaceFolders, append to
-- client.workspace_folders.

---@param client vim.lsp.Client
---@param folder string Absolute path to workspace folder
local function add_workspace_folder(client, folder)
  if vim.fn.isdirectory(folder) == 0 then
    return
  end
  client:_add_workspace_folder(folder)
end

--- Read .bemol/ws_root_folders and add each folder to the given LSP client.
---@param client vim.lsp.Client
---@param root_dir? string Amazon project root directory
---@return boolean added True if any folders were added
function M.load_bemol_workspace_folders(client, root_dir)
  if not root_dir then
    return false
  end
  local ws_file = root_dir .. "/.bemol/ws_root_folders"
  if vim.fn.filereadable(ws_file) ~= 1 then
    return false
  end
  local added = false
  for line in io.lines(ws_file) do
    if line ~= "" then
      add_workspace_folder(client, line)
      added = true
    end
  end
  return added
end

--- Re-read .bemol/ws_root_folders and add folders to all active LSP clients.
--- Call after running bemol in a terminal, or use :Bemol to run it directly.
---@param root_dir? string Amazon project root (auto-detected from current buffer if nil)
function M.bemol_refresh(root_dir)
  if not root_dir then
    root_dir = M.amazon_root(vim.api.nvim_buf_get_name(0))
  end
  if not root_dir then
    vim.notify("Not in an Amazon project", vim.log.levels.WARN)
    return
  end
  local count = 0
  for _, client in ipairs(vim.lsp.get_clients()) do
    if M.load_bemol_workspace_folders(client, root_dir) then
      count = count + 1
    end
  end
  if count > 0 then
    vim.notify(("Refreshed bemol workspace folders for %d client(s)"):format(count))
  else
    vim.notify("No .bemol/ws_root_folders found", vim.log.levels.WARN)
  end
end

--- Run bemol asynchronously and refresh workspace folders on completion.
--- Non-blocking: uses vim.system() with a callback.
---@param root_dir? string Amazon project root (auto-detected from current buffer if nil)
function M.bemol_run(root_dir)
  if vim.fn.executable("bemol") == 0 then
    vim.notify("bemol not installed", vim.log.levels.WARN)
    return
  end
  if not root_dir then
    root_dir = M.amazon_root(vim.api.nvim_buf_get_name(0))
  end
  if not root_dir then
    vim.notify("Not in an Amazon project", vim.log.levels.WARN)
    return
  end

  vim.notify("Running bemol...")
  vim.system({ "bemol", "--verbose" }, { cwd = root_dir, text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        local msg = (result.stderr or ""):gsub("%s+$", "")
        vim.notify("bemol failed (exit " .. result.code .. "): " .. msg, vim.log.levels.ERROR)
        return
      end
      M.bemol_refresh(root_dir)
    end)
  end)
end

return M
