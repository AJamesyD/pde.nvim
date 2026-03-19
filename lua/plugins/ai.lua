local util = require("util")

require("snacks")
  .toggle({
    name = "CodeCompanion",
    get = function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "codecompanion" then
          return true
        end
      end
      return false
    end,
    set = function(_)
      require("codecompanion").toggle({
        window_opts = {
          width = util.min_sidebar_size(35, vim.o.columns, 0.3),
        },
      })
    end,
    notify = false,
  })
  :map("<leader>aa")

return {
  -- Other
  {
    "olimorris/codecompanion.nvim",
    version = "^19.0.0",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "codecompanion" },
      },
      "ravitemer/mcphub.nvim",
    },
    build = false, -- nix-managed
    cmd = {
      "CodeCompanion",
      "CodeCompanionChat",
      "CodeCompanionCmd",
      "CodeCompanionActions",
    },
    opts = function(_, opts)
      vim.api.nvim_create_autocmd({ "DirChanged" }, {
        callback = vim.schedule_wrap(function()
          local config = require("codecompanion.config")
          if not config.interactions then
            return
          end
          local root = LazyVim.root()
          local has_symposium = vim.fn.executable("symposium-acp-agent") == 1
          local adapter = (has_symposium and vim.fn.filereadable(root .. "/Cargo.toml") == 1)
            and "symposium" or "kiro"
          for _, interaction in pairs(config.interactions) do
            if type(interaction) == "table" and interaction.adapter then
              interaction.adapter = adapter
            end
          end
        end),
      })

      local overrides = {
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
          http = {
            opts = { show_presets = false },
          },
          acp = {
            opts = { show_presets = false },
            symposium = function()
              local helpers = require("codecompanion.adapters.acp.helpers")
              return require("codecompanion.adapters.acp").new({
                name = "symposium",
                formatted_name = "Symposium",
                type = "acp",
                roles = { llm = "assistant", user = "user" },
                commands = {
                  default = {
                    "symposium-acp-agent",
                    "run",
                  },
                },
                -- mcpServers required by v19 session/new (sent as-is in the ACP request)
                -- 2 min: mod startup + Sparkle embodiment can be slow
                defaults = { mcpServers = {}, timeout = 120000 },
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
            kiro = function()
              return require("codecompanion.adapters.acp").extend("kiro", {
                commands = { default = { "kiro-cli", "acp", "--agent", "nvim" } },
                -- 1 min; handshake-only, not conversation streaming
                defaults = { timeout = 60000 },
              })
            end,
            opencode = "opencode",
          },
        },
        interactions = {
          shared = {
            rules = {
              -- backends load their own steering; Claude Code rules are redundant
              ["Default"] = { enabled = false },
            },
          },
          chat = {
            adapter = "kiro",
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
          inline = { adapter = "kiro" },
          cmd = { adapter = "kiro" },
        },
        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
              make_tools = true,
              show_server_tools_in_chat = true,
              add_mcp_prefix_to_tool_names = false,
              show_result_in_chat = true,
              format_tool = nil,
              -- TODO: re-enable after mcphub fixes CodeCompanion v19 editor_context rename (ravitemer/mcphub.nvim#277)
              make_vars = false,
              make_slash_commands = true,
            },
          },
        },
      }

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
  },
  {
    "ravitemer/mcphub.nvim",
    optional = true,
    lazy = true,
    build = false, -- nix-managed
    cmd = "MCPHub",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = true,
  },
}
