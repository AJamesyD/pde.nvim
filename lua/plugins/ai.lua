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
    opts = function(_, opts)
      local overrides = {
        provider = "bedrock",
        openai = {
          -- TODO: Make toggle-able
          model = "o3-mini",
          max_tokens = 8192,
        },
        bedrock = {
          -- TODO: Get rate limit increased for 3.7
          -- model = "us.anthropic.claude-3-7-sonnet-20250219-v1:0",
          model = "us.anthropic.claude-3-5-sonnet-20241022-v2:0",
          max_tokens = 16384,
        },
        deepseek = {
          __inherited_from = "bedrock",
          model = "us.deepseek.r1-v1:0",
          max_tokens = 16384,
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
        system_prompt = function()
          local hub = require("mcphub").get_hub_instance()
          return hub and hub:get_active_servers_prompt() or ""
        end,
        -- Using function prevents requiring mcphub before it's loaded
        custom_tools = function()
          return {
            require("mcphub.extensions.avante").mcp_tool(),
          }
        end,
      }

      if require("util").amazon.is_amazon() then
        overrides = vim.tbl_deep_extend("force", overrides, {
          provider = "bedrock",
          cursor_applying_provider = "bedrock",
          behaviour = {
            enable_cursor_planning_mode = true,
          },
        })
        overrides.behaviour.enable_cursor_planning_mode = true
        require("util").amazon.set_bedrock_keys()
      end

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
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
      {
        "ravitemer/mcphub.nvim",
        cmd = "MCPHub",
        dependencies = {
          "nvim-lua/plenary.nvim",
        },
        config = function()
          require("mcphub").setup()
        end,
      },
    },
  },
}
