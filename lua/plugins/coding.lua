return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "lukas-reineke/cmp-under-comparator",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")

      opts.window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      }

      table.insert(opts.sorting.comparators, 4, require("cmp-under-comparator").under)

      return opts
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      {
        "Exafunction/codeium.nvim",
        enabled = false,
        cmd = "Codeium",
        build = ":Codeium Auth",
        opts = {},
      },
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      table.insert(opts.sources, 1, {
        name = "codeium",
        group_index = 1,
        priority = 100,
        max_item_count = 3,
        entry_filter = function(_, _)
          return vim.g.codeium_enabled
        end,
      })
    end,
  },
  {
    "supermaven-inc/supermaven-nvim",
    build = ":SupermavenUseFree",
    opts = {
      keymaps = {
        accept_suggestion = "<C-S-y>",
        clear_suggestion = "<C-n>",
        accept_word = "<C-y>",
      },
    },
  },
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      openai_params = {
        model = "gpt-4-turbo-preview",
      },
      openai_edit_params = {
        model = "gpt-4-turbo-preview",
      },
    },
    config = true,
  },
}
