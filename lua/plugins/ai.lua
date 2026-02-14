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
    "olimorris/codecompanion.nvim",
    version = "^18.0.0",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "codecompanion" },
      },
      "ravitemer/mcphub.nvim",
    },
    build = "npm install -g @zed-industries/claude-code-acp",
    cmd = {
      "CodeCompanion",
      "CodeCompanionChat",
      "CodeCompanionCmd",
      "CodeCompanionActions",
    },
    keys = {
      {
        "<leader>aa",
        function()
          require("codecompanion").toggle({
            window_opts = {
              width = MyUtils.min_sidebar_size(40, vim.o.columns, 0.3),
            },
          })
        end,
        "Toggle AI Chat",
      },
    },
    opts = {
      display = {
        chat = {
          window = {
            width = 0.35,
            opts = {
              number = false,
              relativenumber = false,
            },
          },
        },
      },
      adapters = {
        acp = {
          symposium = function()
            local helpers = require("codecompanion.adapters.acp.helpers")
            return require("codecompanion.adapters.acp").new({
              name = "symposium",
              formatted_name = "Symposium",
              type = "acp",
              roles = { llm = "assistant", user = "user" },
              commands = {
                default = {
                  vim.fn.expand("~/.cargo/bin/symposium-acp-agent"),
                  "run",
                },
              },
              defaults = { timeout = 30000 },
              parameters = {
                protocolVersion = 1,
                clientCapabilities = {
                  fs = { readTextFile = true, writeTextFile = true },
                },
                clientInfo = { name = "CodeCompanion.nvim", version = "1.0.0" },
              },
              handlers = {
                setup = function() return true end,
                form_messages = function(self, messages, capabilities)
                  return helpers.form_messages(self, messages, capabilities)
                end,
                on_exit = function() end,
              },
            })
          end,
        },
      },
      interactions = {
        chat = {
          tools = {
            groups = {
              ["github_pr_workflow"] = {
                description = "GitHub operations from issue to PR",
                tools = {
                  -- File operations
                  "neovim__read_multiple_files",
                  "neovim__write_file",
                  "neovim__edit_file",
                  -- GitHub operations
                  "github__list_issues",
                  "github__get_issue",
                  "github__get_issue_comments",
                  "github__create_issue",
                  "github__create_pull_request",
                  "github__get_file_contents",
                  "github__create_or_update_file",
                  "github__search_code",
                },
              },
            },
          },
        },
      },
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            -- MCP Tools
            make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
            show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
            add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
            show_result_in_chat = true, -- Show tool results directly in chat buffer
            format_tool = nil, -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
            -- MCP Resources
            make_vars = true, -- Convert MCP resources to #variables for prompts
            -- MCP Prompts
            make_slash_commands = true, -- Add MCP prompts as /slash commands
          },
        },
      },
      strategies = {
        chat = { adapter = "symposium" },
        inline = { adapter = "symposium" },
        cmd = { adapter = "symposium" },
      },
    },
  },
  {
    "yetone/avante.nvim",
    lazy = true,
    enabled = false,
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
            model = "us.anthropic.claude-sonnet-4-20250514-v1:0",
            aws_profile = "bedrock",
            aws_region = "us-west-2",
            timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
            extra_request_body = {
              max_tokens = 40960, -- Increase this to include reasoning tokens (for reasoning models)
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

      if require("util").amazon.is_amazon_machine() then
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
        ft = { "markdown", "Avante" },
        opts = {
          file_types = { "markdown", "Avante" },
        },
      },
      {
        "ravitemer/mcphub.nvim",
        build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
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
  {
    "ravitemer/mcphub.nvim",
    optional = true,
    lazy = true,
    build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
    cmd = "MCPHub",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("mcphub").setup()
    end,
  },
  {
    "coder/claudecode.nvim",
    optional = true,
    opts = {
      terminal = {
        split_side = "left", -- flipped to right by current edgy.nvim config
      },
    },
    config = true,
  },
}
