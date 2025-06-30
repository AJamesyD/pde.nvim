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
        function() end,
      },
      {
        -- Avante sets its own keymaps, but I still want to lazy load it to speed up startup
        "<leader>aa",
        "AvanteAsk",
        desc = "avante: ask",
      },
    },
    cmd = {
      "AvanteAsk",
      "AvanteChat",
      "AvanteChatNew",
      "AvanteEdit",
      "AvanteToggle",
    },
    version = false, -- set this if you want to always pull the latest change
    opts = function(_, opts)
      local overrides = {
        provider = "bedrock",
        mode = "legacy", -- https://github.com/yetone/avante.nvim/issues/2100
        disabled_tools = {
          "web_search",
        },
        providers = {
          openai = {
            -- TODO: Make toggle-able
            model = "o3-mini",
            extra_request_body = {
              max_tokens = 8192,
            },
          },
          bedrock = {
            model = "us.anthropic.claude-3-7-sonnet-20250219-v1:0",
            aws_profile = "bedrock",
            aws_region = "us-west-2",
            -- disable_tools = true,
            extra_request_body = {
              -- timeout = 10000, -- Timeout in milliseconds, increase this for reasoning models
              -- max_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
            },
          },
          deepseek = {
            __inherited_from = "bedrock",
            model = "us.deepseek.r1-v1:0",
          },
        },
        windows = {
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
        vim.schedule(require("util").amazon.set_bedrock_keys)
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
          require("mcphub").setup({
            extensions = {
              avante = {
                make_slash_commands = true, -- make /slash commands from MCP server prompts
              },
            },
          })
        end,
      },
    },
  },
}
