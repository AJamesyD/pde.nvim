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

---@param bufnr? integer
M.is_bemol_proj = function(bufnr)
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local filetype = vim.bo[bufnr].filetype

  local is_brazil_broj = M.brazil_root(filepath) and vim.tbl_contains(BRAZIL_SUPPORTED_FTS, filetype)
  local is_peru_proj = M.peru_root(filepath) and vim.tbl_contains(PERU_SUPPORTED_FTS, filetype)

  return is_brazil_broj or is_peru_proj
end

M.bemol = function()
  if vim.fn.executable("bemol") == 0 then
    vim.notify("bemol not installed.", vim.log.levels.WARN)
    return
  end

  local ok, overseer = pcall(require, "overseer")
  if not ok then
    vim.notify("overseer.nvim not installed. Must run bemol manually.", vim.log.levels.WARN)
    return
  end

  ---@type overseer.TemplateDefinition
  local bemol_init_task_def = {
    name = "bemol",
    builder = function()
      ---@type overseer.TaskDefinition
      return {
        cmd = { "bemol" },
        components = {
          { "amazon.lsp_setup" }, -- custom component
          "default",
        },
      }
    end,
  }
  overseer.register_template(bemol_init_task_def)

  ---@type overseer.TemplateDefinition
  local bemol_ongoing_task_def = {
    name = "bemol watch",
    builder = function()
      ---@type overseer.TaskDefinition
      return {
        cmd = { "bemol" },
        args = { "--watch", "--verbose" },
      }
    end,
  }
  overseer.register_template(bemol_ongoing_task_def)

  ---@type overseer.TemplateDefinition
  local bemol_task_def = {
    name = "Bemol LSP Setup",
    strategy = {
      "orchestrator",
      tasks = {
        "bemol",
        "bemol watch",
      },
    },
  }
  local bemol_task = overseer.new_task(bemol_task_def)

  -- HACK: Delay bemol, otherwise it fails
  vim.defer_fn(function()
    bemol_task:start()
  end, 500)
end

return M
