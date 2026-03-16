-- ty (Astral) experiment: replacing basedpyright with ty
--
-- ty is Astral's Rust-based type checker (beta, March 2026). ~80x faster incremental
-- checks than pyright, but 53% typing conformance vs pyright's 98%.
-- See: https://docs.astral.sh/ty/editors/neovim/
--
-- ty + ruff split:
--   ty:   type checking, completions, hover, goto-def, rename, inlay hints, find refs
--   ruff: formatting, linting, organize imports (ty has no formatter)
--
-- bemol: generates ty.toml natively (opt-in via language-servers = ['ty'] in .bemol config)
--   No pythonPath bridge needed unlike basedpyright.
--   See: bemol source src/bemol/lang/python.py (_write_ty_settings)
--
-- Known issues:
--   - :edit removes diagnostics until next change (ty#3010)
--   - Some setups need explicit cmd (ty#2616)
--
-- Prior art: EcglasNvim, SabebDotfiles, Butryan_dotfiles (code.amazon.com)

return {
  -- Reconfigure LazyVim defaults
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      servers = {
        -- Disable basedpyright/pyright (LazyVim python extra enables one of these)
        basedpyright = { enabled = false },
        pyright = { enabled = false },

        ty = {
          cmd = { "ty", "server" }, -- explicit cmd avoids ty#2616
          settings = {
            ty = {
              showSyntaxErrors = false, -- ruff handles syntax errors
              diagnosticMode = "openFilesOnly",
              completions = { autoImport = true },
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
            -- ty uses `# ty: ignore` not `# pyright: ignore`, but respects
            -- `# type: ignore` (PEP 484). Use the standard form for otter.
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
