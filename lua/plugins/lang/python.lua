return {
  -- Reconfigure LazyVim defaults
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      servers = {
        basedpyright = {
          settings = {
            basedpyright = {
              disableLanguageServices = false,
              disableOrganizeImports = true,
              disableTaggedHints = false,
              analysis = {
                autoImportCompletions = true,
                autoSearchPaths = true,
                typeCheckingMode = "basic",
              },
            },
          },
        },
        pyright = {
          settings = {
            basedpyright = {
              disableLanguageServices = false,
              disableOrganizeImports = true,
              disableTaggedHints = false,
              analysis = {
                autoImportCompletions = true,
                autoSearchPaths = true,
                typeCheckingMode = "standard",
              },
            },
          },
        },
        pylsp = {
          settings = {
            pylsp = {
              configurationSources = { "flake8" },
              plugins = {
                autopep8 = {
                  enabled = false,
                },
                flake8 = {
                  enabled = false,
                },
                jedi_completion = {
                  enabled = false,
                },
                jedi_definition = {
                  enabled = false,
                },
                jedi_hover = {
                  enabled = false,
                },
                jedi_references = {
                  enabled = false,
                },
                jedi_signature_help = {
                  enabled = false,
                },
                jedi_symbols = {
                  enabled = false,
                },
                mccabe = {
                  enabled = false,
                },
                pycodestyle = {
                  enabled = false,
                },
                pyflakes = {
                  enabled = false,
                },
                rope_completion = {
                  enabled = false,
                },
                rope_autoimport = {
                  enabled = false,
                },
                yapf = {
                  enabled = false,
                },
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
