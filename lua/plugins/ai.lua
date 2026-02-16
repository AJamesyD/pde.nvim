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
                setup = function()
                  return true
                end,
                form_messages = function(self, messages, capabilities)
                  return helpers.form_messages(self, messages, capabilities)
                end,
                on_exit = function() end,
              },
            })
          end,
          kiro = "kiro",
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
    "ravitemer/mcphub.nvim",
    optional = true,
    lazy = true,
    build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
    cmd = "MCPHub",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = true,
  },
}
