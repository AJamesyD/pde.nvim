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
  "codediff-explorer",
  "codediff-history",
  "codediff-help",
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

-- Structural LSP symbol kinds for outline/aerial filters.
-- Types, callables, and module boundaries only.
-- Excludes: too granular (Property, Field, Variable, Constant, Parameter, EnumMember),
-- literal values (String, Number, Boolean, Array, Key, Null),
-- niche (Event, Operator, TypeParameter, StaticMethod),
-- framework-specific (Component, Fragment),
-- redundant (File, Package).
M.OUTLINE_SYMBOLS = {
  "Class",
  "Constructor",
  "Enum",
  "Function",
  "Interface",
  "Method",
  "Module",
  "Namespace",
  "Struct",
}
-- Rust adds macro and impl block symbols to the base set.
M.OUTLINE_SYMBOLS_RUST = vim.list_extend({
  "Macro",
  "Object",
}, vim.deepcopy(M.OUTLINE_SYMBOLS))

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
  if not full_file_name or full_file_name == "" then
    -- Unnamed buffers (scratch, new files) default to relevant so they
    -- aren't unlisted by the BufWinEnter autocmd before the user saves.
    vim.b[bufnr].is_relevant_file = true
    return true
  end

  local cwd = LazyVim.root.cwd()
  local root = LazyVim.root.get({ normalize = true, buf = bufnr })

  local cwd_in_root = root:find(cwd, 1, true) == 1
  local root_in_cwd = cwd:find(root, 1, true) == 1
  if not cwd_in_root and not root_in_cwd then
    vim.b[bufnr].is_relevant_file = false
    return false
  end

  -- Check if the file lives under the project root.
  -- Simpler and non-blocking compared to the previous fd-based approach.
  -- Trade-off: gitignored files (target/, node_modules/) under root are
  -- now considered relevant, but this rarely matters in practice.
  local normalized = vim.fs.normalize(full_file_name)
  local is_relevant = vim.startswith(normalized, root)
  vim.b[bufnr].is_relevant_file = is_relevant
  return is_relevant
end

---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts? vim.keymap.set.Opts
M.map = function(mode, lhs, rhs, opts)
  opts = opts or {}
  -- vim.keymap.set defaults to silent = false; prefer silent for custom maps
  -- to avoid "hit-enter" prompts on command-based mappings (e.g., shpool detach).
  if opts.silent == nil then
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

--- Build a dropbar-style path for the winbar: dir › dir › 󰈙 file.lua ●
--- Uses vim statusline highlight escapes: %#Group# sets highlight, %* resets.
---@return string
M.format_winbar_path = function()
  if vim.bo.buftype ~= "" then
    return ""
  end -- skip special buffers (terminal, help, etc.)
  local path = vim.fn.expand("%:~:.")
  if path == "" or path == "." then
    return ""
  end

  local sep = " %#NonText#›%* "
  local segments = vim.split(path, "/")

  local ok, devicons = pcall(require, "nvim-web-devicons")
  if ok and #segments > 0 then
    local icon, hl = devicons.get_icon(vim.fn.expand("%:t"), vim.fn.expand("%:e"), { default = true })
    if icon then
      segments[#segments] = "%#" .. (hl or "Normal") .. "#" .. icon .. "%* " .. segments[#segments]
    end
  end

  if vim.bo.modified then
    segments[#segments] = segments[#segments] .. " %#DiagnosticWarn#●%*"
  elseif vim.bo.readonly then
    segments[#segments] = segments[#segments] .. " %#DiagnosticError#󰌾%*"
  end

  return table.concat(segments, sep)
end

M.amazon = require("util.amazon")

return M
