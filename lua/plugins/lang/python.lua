-- basedpyright + bemol pythonPath bridge
--
-- Problem: bemol generates pyrightconfig.json with venvPath/venv fields, which
-- basedpyright marks as "discouraged" and doesn't resolve the same way pyright does.
-- See: https://docs.basedpyright.com/latest/configuration/config-files/ (discouraged settings)
--
-- Fix: on_init reads bemol's pyrightconfig.json and passes the venv interpreter
-- as python.pythonPath, which basedpyright fully supports.
-- Prior art: Cladam-settings, Nzimmerl dotfiles (code.amazon.com)

--- Read bemol's pyrightconfig.json and return the venv python path, or nil.
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
  -- Reconfigure LazyVim defaults
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      servers = {
        basedpyright = {
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
              },
            },
          },
        },
      },
    },
  },

  -- Other
  {
    "jmbuhr/otter.nvim",
    optional = true,
    opts = {
      buffers = {
        preambles = {
          python = {
            "# pyright: reportMissingImports=false, reportMissingModuleSource=false",
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
