-- Many of the following utils are ~~plagiarized from~~ inspired by https://github.com/nvim-telescope/telescope.nvim

local M = {}

-- Statusline responsive breakpoints (vim.o.columns thresholds)
M.WIDTH_AERIAL = 120 -- hide aerial breadcrumbs
M.WIDTH_BRANCH = 100 -- hide branch
M.WIDTH_PROGRESS = 80 -- hide progress/location

-- Filetypes for UI chrome / non-editor buffers. Used by multiple plugins
-- (lualine winbar, smartcolumn, colorful-winsep) to skip decoration.
M.SPECIAL_FILETYPES = {
  "DiffviewFiles",
  "TelescopePrompt",
  "TelescopeResults",
  "trouble",
  "alpha",
  "dashboard",
  "lazy",
  "mason",
  "neo-tree",
  "notify",
  "snacks_dashboard",
  "snacks_notif",
  "snacks_terminal",
  "snacks_win",
  "toggleterm",
}

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

  local result = vim.system(find_command, { text = true }):wait()
  if result.code ~= 0 then
    vim.notify("fd command failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
    vim.b[bufnr].is_relevant_file = true
    return true
  end

  local found = vim.trim(result.stdout or "")
  if found == "" then
    vim.b[bufnr].is_relevant_file = false
    return false
  end
  vim.b[bufnr].is_relevant_file = true
  return true
end

---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts? vim.keymap.set.Opts
M.map = function(mode, lhs, rhs, opts)
  opts = opts or {}

  -- Default is no recursive remap
  if type(opts.remap) == "boolean" then
    opts.remap = opts.remap
  elseif type(opts.noremap) == "boolean" then
    opts.noremap = opts.noremap
  end

  -- Unsure of what default is, but I want it to be silent
  if type(opts.silent) == "nil" then
    opts.silent = true
  end

  vim.keymap.set(mode, lhs, rhs, opts)
end

---@param min_size integer
---@param max_size integer
---@param fraction_of_max number
---@return number
M.min_sidebar_size = function(min_size, max_size, fraction_of_max)
  return math.max(math.floor(max_size * fraction_of_max), min_size)
end

--- Shorten a git branch name by stripping noise and keeping the most useful signal.
--- Pure string logic — no vim dependencies, so it's testable outside neovim.
---@param name string raw branch name
---@param max_len? integer hard cap (default 15% of columns). 0 = no cap.
---@return string
M.format_branch = function(name, max_len)
  max_len = max_len or math.floor(vim.o.columns * 0.15)
  local result = name

  -- Strip username prefix (2+ slashes)
  local slash_count = 0
  for _ in result:gmatch("/") do
    slash_count = slash_count + 1
  end
  if slash_count >= 2 then
    result = result:match("^[^/]+/(.+)$") or result
  end

  -- Strip conventional prefixes only when over max_len
  if #result > max_len then
    local prefixes = {
      "feature/",
      "feat/",
      "bugfix/",
      "fix/",
      "hotfix/",
      "release/",
      "chore/",
      "docs/",
      "refactor/",
      "ci/",
      "test/",
      "perf/",
      "build/",
      "style/",
    }
    for _, prefix in ipairs(prefixes) do
      if result:sub(1, #prefix) == prefix then
        result = result:sub(#prefix + 1)
        break
      end
    end
  end

  -- Extract ticket if present, drop description after it
  local ticket = result:match("^([A-Z]+%-[0-9]+)")
  if ticket then
    local after_ticket = result:sub(#ticket + 1)
    if after_ticket:match("^[-_]") then
      result = ticket
    end
  end

  -- Hard cap
  if max_len > 0 and #result > max_len then
    return result:sub(1, max_len - 1) .. "…"
  end

  return result
end

---Shorten aerial breadcrumbs by dropping leftmost ancestors.
---Uses statusline highlight codes to preserve per-kind coloring.
---@param symbols table[]? from aerial.get_location()
---@param max_len? integer Default: 40% of columns
M.format_aerial = function(symbols, max_len)
  if not symbols or #symbols == 0 then
    return ""
  end
  max_len = max_len or math.floor(vim.o.columns * 0.4)

  local sep = " › "
  local sep_w = vim.api.nvim_strwidth(sep)
  local elide = "… › "
  local elide_w = vim.api.nvim_strwidth(elide)

  local parts = {}
  for _, s in ipairs(symbols) do
    local icon = s.icon or ""
    local text = icon ~= "" and (icon .. " " .. s.name) or s.name
    local hl = s.kind and ("%#Aerial" .. s.kind .. "Icon#" .. icon .. " %#Aerial" .. s.kind .. "#" .. s.name) or text
    table.insert(parts, { w = vim.api.nvim_strwidth(text), hl = hl })
  end

  local function width(from)
    local w = from > 1 and elide_w or 0
    for i = from, #parts do
      if i > from then
        w = w + sep_w
      end
      w = w + parts[i].w
    end
    return w
  end

  local start = 1
  while start < #parts and width(start) > max_len do
    start = start + 1
  end

  local out = {}
  if start > 1 then
    out[1] = elide
  end
  for i = start, #parts do
    if i > start then
      table.insert(out, "%#NonText#" .. sep)
    end
    table.insert(out, parts[i].hl)
  end
  return table.concat(out)
end

M.amazon = require("util.amazon")

return M
