return {
  -- Reconfigure LazyVim extras
  -- TODO: Re-enable when https://github.com/folke/edgy.nvim/issues/113 resolved
  -- {
  --   "folke/edgy.nvim",
  --   optional = true,
  --   opts = function(_, opts)
  --     -- Will get swapped to right by other edgy conf
  --     ---@type Edgy.View.Opts[]
  --     local left_overrides = {
  --       {
  --         title = "Avante",
  --         ft = "Avante",
  --         size = {
  --           width = MyUtils.min_sidebar_size(40, vim.o.columns, 0.20),
  --         },
  --       },
  --       {
  --         title = "Avante Selected Files",
  --         ft = "AvanteSelectedFiles",
  --         size = {
  --           height = 3,
  --         },
  --       },
  --       {
  --         title = "Avante Input",
  --         ft = "AvanteInput",
  --         size = {
  --           height = MyUtils.min_sidebar_size(10, vim.o.lines, 0.10),
  --         },
  --       },
  --     }
  --
  --     opts.left = opts.left or {}
  --     opts.left = vim.list_extend(left_overrides, opts.left or {})
  --     return opts
  --   end,
  -- },

  -- Other
  {
    "yetone/avante.nvim",
    lazy = true,
    keys = {
      {
        -- Avante sets its own keymaps, but I still want to lazy load it to speed up startup
        "<leader>a",
        function()
          require("avante")
        end,
      },
    },
    version = false, -- set this if you want to always pull the latest change
    opts = {
      provider = "openai",
      ---@type AvanteSupportedProvider
      openai = {
        endpoint = "https://api.openai.com/v1",
        -- TODO: Make toggle-able
        model = "gpt-4o",
        timeout = 30000, -- Timeout in milliseconds
        temperature = 0,
        max_tokens = 4096,
        ["local"] = false,
      },
      behavior = {
        -- auto_set_keymaps = false,
        history = {
          max_tokens = 4096,
        },
      },
      history = {
        max_tokens = 8192,
      },
      windows = {
        -- For use with edgy.nvim
        -- width = 100,
        -- height = 100,
        -- input = {
        --   height = 100,
        -- },
        width = 25,
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      -- "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      -- "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
}
