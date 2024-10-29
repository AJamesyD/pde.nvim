local personal_vault = vim.fn.expand("~") .. "/Documents/Personal-Vault/"
local work_vault = vim.fn.expand("~") .. "/Documents/Work-Vault/"
local markdownlint_config = vim.fn.expand("~") .. "/.config/markdownlint-cli/.markdownlint-cli2.yaml"

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters = {
        ["markdownlint-cli2"] = {
          prepend_args = {
            "--config",
            markdownlint_config,
          },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        ["markdownlint-cli2"] = {
          args = { "--config", markdownlint_config },
        },
      },
    },
  },
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    event = {
      "BufReadPre " .. personal_vault .. ".*md",
      "BufNewFile " .. personal_vault .. ".*md",
      "BufReadPre " .. work_vault .. ".*md",
      "BufNewFile " .. work_vault .. ".*md",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    opts = {
      workspaces = {
        {
          name = "Personal",
          path = personal_vault,
        },
        {
          name = "Work",
          path = work_vault,
        },
      },

      daily_notes = {
        folder = "Daily Notes",
        template = "Daily Note Template.md",
      },

      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },

      new_notes_location = "notes_subdir",

      preferred_link_style = "markdown",

      disable_frontmatter = false,

      templates = {
        folder = "Templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },

      ui = {
        enable = false, -- In favor of render-markdown.nvim
      },

      attachments = {
        img_folder = "Files/Images",
      },
    },
  },
}
