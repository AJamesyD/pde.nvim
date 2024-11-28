-- https://w.amazon.com/bin/view/Bemol#HPluginFeatures
local BRAZIL_SUPPORTED_FTS = {
  "cpp", -- beta
  "c", -- beta
  "java",
  "kotlin", --beta
  "python",
  "ruby",
}
local PERU_SUPPORTED_FTS = {
  "javascript",
  "typescript",
  "python",
}
local M = {}

-- One function's level of indirection required to prevent loading lspconfig early
M.brazil_root = function(...)
  return require("lspconfig.util").root_pattern("Config")(...)
end
M.peru_root = function(...)
  return require("lspconfig.util").root_pattern("brazil.ion")(...)
end

M.is_amazon = function()
  return os.getenv("USER") == "angaidan"
end

---@param bufnr number
---@param dep_model? "brazil"|"peru"|nil
M.is_bemol_proj = function(bufnr, dep_model)
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local filetype = vim.bo[bufnr].filetype

  local is_brazil_broj = M.brazil_root(filepath) and vim.tbl_contains(BRAZIL_SUPPORTED_FTS, filetype)
  local is_peru_proj = M.peru_root(filepath) and vim.tbl_contains(PERU_SUPPORTED_FTS, filetype)

  if dep_model == "brazil" then
    return is_brazil_broj
  elseif dep_model == "peru" then
    return is_peru_proj
  elseif type(dep_model) == "nil" then
    return is_brazil_broj or is_peru_proj
  else
    vim.notify("Project is not supported by bemol", vim.log.levels.WARN)
  end
end

M.bemol = function()
  local bemol_dir = vim.fs.find({ ".bemol" }, { upward = true, type = "directory" })[1]
  local ws_folders_lsp = {}

  if vim.fn.executable("bemol") == 0 then
    vim.notify("bemol not installed", vim.log.levels.WARN)
    return
  end

  -- TODO: Run bemol --watch --verbose
  if not bemol_dir then
    vim.notify("Running bemol...")
    vim.schedule(vim.cmd("!bemol"))
  end

  local ok, overseer = pcall(require, "overseer")
  if ok then
    local task = overseer.new_task({
      cmd = { "bemol" },
      args = { "--watch", "--verbose" },
      components = { { "on_result_notify" }, { "on_complete_restart" }, "default" },
    })
    vim.schedule(function()
      task:start()
    end)
  end
  -- TODO: Add ws folder append to follow up overseer task instead of doing initial blocking call to bemol
  if bemol_dir then
    local file = io.open(bemol_dir .. "/ws_root_folders", "r")
    if file then
      for line in file:lines() do
        table.insert(ws_folders_lsp, line)
      end
      file:close()
    end
  end

  for _, line in ipairs(ws_folders_lsp) do
    vim.lsp.buf.add_workspace_folder(line)
  end
end

return M
