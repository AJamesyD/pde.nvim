-- Python type checker config: ty or basedpyright, controlled by vim.g.python_type_checker
--
-- ty (Astral, beta): ~7-112x faster incremental checks, lower typing conformance.
--   bemol generates ty.toml natively (language-servers = ['ty'] in .bemol config).
--   Known: :edit clears diagnostics until next change (ty#3010), needs explicit cmd (ty#2616).
--
-- basedpyright: high conformance, full LSP feature set (call hierarchy, type hierarchy).
--   bemol generates pyrightconfig.json with venvPath/venv (marked "discouraged" by basedpyright).
--   Workaround: on_init reads bemol's config and passes the interpreter as python.pythonPath.

local use_ty = vim.g.python_type_checker == "ty"

--- Read bemol's pyrightconfig.json and return the venv python path, or nil.
--- Only used when basedpyright is active.
local function bemol_python_path(root_dir)
  local config_path = root_dir and (root_dir .. "/pyrightconfig.json")
  if not config_path or vim.fn.filereadable(config_path) ~= 1 then
    return nil
  end
  local f = io.open(config_path, "r")
  if not f then
    return nil
  end
  local ok, data = pcall(vim.json.decode, f:read("*a"))
  f:close()
  if not ok or not data or not data.venvPath or not data.venv then
    return nil
  end
  local path = data.venvPath .. "/" .. data.venv .. "/bin/python"
  if vim.fn.executable(path) == 1 then
    return path
  end
  return nil
end

return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      servers = {
        -- Always disable pyright; lazyvim_python_lsp is pinned to basedpyright
        -- to prevent LazyVim from enabling pyright as a fallback.
        pyright = { enabled = false },

        basedpyright = use_ty and { enabled = false } or {
          on_init = function(client)
            local python_path = bemol_python_path(client.config.root_dir)
            if python_path then
              client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, {
                python = { pythonPath = python_path },
              })
              client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
            end
          end,
          settings = {
            basedpyright = {
              disableOrganizeImports = true, -- ruff handles this
              analysis = {
                autoImportCompletions = true,
                autoSearchPaths = true,
                typeCheckingMode = "basic",
                -- Suppress diagnostics that overlap with ruff or are
                -- too noisy for third-party code without type stubs.
                diagnosticSeverityOverrides = {
                  reportMissingTypeStubs = false,
                  reportUnusedImport = false, -- ruff F401
                  reportUnusedVariable = false, -- ruff F841
                },
              },
            },
          },
        },

        ty = use_ty and {
          cmd = { "ty", "server" }, -- explicit cmd avoids ty#2616
          settings = {
            ty = {
              showSyntaxErrors = false, -- ruff handles syntax errors
              diagnosticMode = "openFilesOnly",
              completions = { autoImport = true },
            },
          },
        } or { enabled = false },
      },
    },
  },

  {
    "jmbuhr/otter.nvim",
    optional = true,
    opts = {
      buffers = {
        preambles = {
          python = {
            -- `# type: ignore` is PEP 484, respected by both ty and basedpyright.
            "# type: ignore",
            "from __future__ import annotations",
            "from typing import *",
            "import os, sys, json, re, math",
            "import itertools, functools, datetime",
            "from pathlib import Path",
            "from collections import defaultdict, Counter, OrderedDict",
            "from dataclasses import dataclass, field",
          },
        },
        ignore_pattern = { python = "^(%s*[%%!].*)" },
      },
    },
  },
}
