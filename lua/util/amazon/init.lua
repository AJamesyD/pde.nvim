-- https://w.amazon.com/bin/view/Bemol#HPluginFeatures
local BRAZIL_BEMOL_SUPPORTED_FTS = {
  "cpp", -- beta
  "c", -- beta
  "java",
  "kotlin", --beta
  "python",
  "ruby",
}
local PERU_BEMOL_SUPPORTED_FTS = {
  "javascript",
  "typescript",
  "python",
}

local M = {}

M.brazil_root = function(filename)
  local root_file = vim.fs.find(function(name, _)
    return name:match("^Config$")
  end, { path = filename, type = "file", upward = true })[1]
  return vim.fs.dirname(root_file)
end
M.peru_root = function(filename)
  local root_file = vim.fs.find(function(name, _)
    return name:match("^brazil%.ion$")
  end, { path = filename, type = "file", upward = true })[1]
  return vim.fs.dirname(root_file)
end
---@param filename string
---@param build_system? "brazil"|"peru"
--- Build system. Defaults to both Brazil and Peru
M.amazon_root = function(filename, build_system)
  local root_file = vim.fs.find(function(name, _)
    local is_brazil = name:match("^Config$")
    local is_peru = name:match("^brazil%.ion$")
    if build_system == "brazil" then
      return is_brazil
    elseif build_system == "peru" then
      return is_peru
    end
    return is_brazil or is_peru
  end, { path = filename, type = "file", upward = true })[1]
  return vim.fs.dirname(root_file)
end

M.is_amazon_machine = function()
  return os.getenv("USER") == "angaidan"
end

---@param bufnr? integer
M.is_bemol_proj = function(bufnr)
  if type(bufnr) == "nil" then
    bufnr = 0 -- Current bufnr
  end
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local filetype = vim.bo[bufnr].filetype

  local is_brazil_broj = M.brazil_root(filepath) and vim.tbl_contains(BRAZIL_BEMOL_SUPPORTED_FTS, filetype)
  local is_peru_proj = M.peru_root(filepath) and vim.tbl_contains(PERU_BEMOL_SUPPORTED_FTS, filetype)

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
        args = { "--verbose" },
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

M.set_bedrock_keys = function()
  local profile = "bedrock"
  local credentials = vim
    .system({ "aws", "configure", "export-credentials", "--profile", profile }, { text = true })
    :wait()
  if credentials.code ~= 0 then
    vim.notify(vim.trim(credentials.stderr), vim.log.levels.ERROR)
    return
  end
  local cred_data = vim.json.decode(credentials.stdout)
  local region = vim.system({ "aws", "configure", "get", "region", "--profile", profile }, { text = true }):wait()
  if region.code ~= 0 then
    vim.notify(vim.trim(region.stderr), vim.log.levels.ERROR)
    return
  end
  local region_text = vim.trim(region.stdout)
  local bedrock_keys = table.concat({
    cred_data.AccessKeyId,
    cred_data.SecretAccessKey,
    region_text,
    cred_data.SessionToken,
  }, ",")
  vim.env.BEDROCK_KEYS = bedrock_keys
  vim.notify(string.format("BEDROCK_KEYS set for profile %s in region %s", profile, region_text), vim.log.levels.INFO)
end

return M
