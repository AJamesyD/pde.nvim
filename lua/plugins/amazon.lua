local util = require("util")

if not util.amazon.is_amazon_machine() then
  return {}
end

-- Detect Brazil workspace from cwd (used to conditionally load Amazon plugins)
local in_brazil = util.amazon.amazon_root(vim.fn.getcwd()) ~= nil

-- VimIon provides ftdetect for *.ion, but only loads on ft = "ion".
-- Register the extension here so the filetype is set before the plugin loads.
vim.filetype.add({ extension = { ion = "ion" } })

-- Barium LSP for brazil-config files (native Neovim 0.11+ config, no lspconfig needed).
-- VimBrazilConfig handles ftdetect and sets the brazil-config filetype.
vim.lsp.config.barium = {
  cmd = { "barium" },
  root_markers = { "Config" },
  filetypes = { "brazil-config" },
}
vim.lsp.enable("barium")

return {
  -- Reconfigure LazyVim defaults
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        ion = {
          command = "ion",
          args = { "cat", "--format", "pretty" },
        },
      },
      formatters_by_ft = {
        ion = { "ion" },
      },
    },
  },

  -- Reconfigure LazyVim extras
  {
    "stevearc/overseer.nvim",
    optional = true,
    ---@param opts overseer.Config
    opts = function(_, opts)
      local overseer = require("overseer")
      overseer.register_template({
        name = "brazil build package (bb)",
        builder = function()
          ---@type overseer.TaskDefinition
          return {
            cmd = { "brazil-build" },
          }
        end,
      })
      overseer.register_template({
        name = "brazil build workspace (bbb)",
        builder = function()
          ---@type overseer.TaskDefinition
          return {
            cmd = { "brazil-recursive-cmd" },
            args = { "--allPackages", "brazil-build" },
          }
        end,
      })

      return opts
    end,
  },
  {
    "folke/snacks.nvim",
    ---@type snacks.Config.base
    opts = {
      ---@type snacks.gitbrowse.Config
      ---@diagnostic disable-next-line: missing-fields
      gitbrowse = {
        url_patterns = {
          ["code.amazon.com"] = {
            branch = "trees/{branch}",
            file = "/blobs/{branch}/--/{file}#L{line_start}-L{line_end}",
            permalink = "/blobs/{commit}/--/{file}#L{line_start}-L{line_end}",
            commit = "/commits/{commit}",
          },
        },

        remote_patterns = {
          -- Amazon specific pattern
          { "^ssh://git.amazon.com:2222/pkg/(.+)$", "https://code.amazon.com/packages/%1" },
          { "^https://git.amazon.com:2222/pkg/(.+)$", "https://code.amazon.com/packages/%1" },

          -- Original patterns
          { "^(https?://.*)%.git$", "%1" },
          { "^git@(.+):(.+)%.git$", "https://%1/%2" },
          { "^git@(.+):(.+)$", "https://%1/%2" },
          { "^git@(.+)/(.+)$", "https://%1/%2" },
          { "^org%-%d+@(.+):(.+)%.git$", "https://%1/%2" },
          { "^ssh://git@(.*)$", "https://%1" },
          { "^ssh://([^:/]+)(:%d+)/(.*)$", "https://%1/%3" },
          { "^ssh://([^/]+)/(.*)$", "https://%1/%2" },
          { "ssh%.dev%.azure%.com/v3/(.*)/(.*)$", "dev.azure.com/%1/_git/%2" },
          { "^https://%w*@(.*)", "https://%1" },
          { "^git@(.*)", "https://%1" },
          { ":%d+", "" },
          { "%.git$", "" },
        },
      },
      ---@type snacks.indent.Config
      ---@diagnostic disable-next-line: missing-fields
      indent = {
        filter = function(buf, win)
          return vim.bo[buf].filetype ~= "crux_thread"
            and vim.g.snacks_indent ~= false
            and vim.b[buf].snacks_indent ~= false
            and vim.bo[buf].buftype == ""
        end,
      },
    },
  },

  -- Other
  -- Provides ftdetect, syntax, indent, and ftplugin for brazil-config files.
  -- Loads eagerly in Brazil workspaces so its ftdetect registers before any Config file opens.
  {
    url = "angaidan@git.amazon.com:pkg/VimBrazilConfig",
    branch = "mainline",
    cond = in_brazil,
    lazy = false,
  },
  -- Provides syntax, indent, and ftplugin for Amazon Ion files.
  -- Lazy-loaded on ft because vim.filetype.add above handles *.ion detection.
  {
    url = "angaidan@git.amazon.com:pkg/VimIon",
    branch = "mainline",
    cond = in_brazil,
    ft = "ion",
  },
  {
    "AJamesyD/crux.nvim",
    dev = true,
    cond = require("util").amazon.is_amazon_machine(),
    name = "crux",
    cmd = "Cr",
    dependencies = {
      {
        "folke/lazydev.nvim",
        optional = true,
        opts = function(_, opts)
          opts.library = opts.library or {}
          table.insert(opts.library, { path = "crux", words = { "crux" } })
        end,
      },
      {
        "folke/which-key.nvim",
        optional = true,
        opts = {
          spec = { { "<leader>r", group = "review", icon = "💬" } },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        optional = true,
        opts = { file_types = { "markdown", "crux_thread" } },
        ft = { "markdown", "crux_thread" },
      },
      {
        "folke/trouble.nvim",
        optional = true,
      },
      {
        "nvim-lualine/lualine.nvim",
        optional = true,
        opts = function(_, opts)
          opts.sections = opts.sections or {}
          opts.sections.lualine_x = opts.sections.lualine_x or {}
          table.insert(opts.sections.lualine_x, 1, {
            function()
              return require("crux").statusline() or ""
            end,
            cond = function()
              return package.loaded["crux"] and require("crux").is_active()
            end,
          })
        end,
      },
    },
    keys = {
      { "<leader>ro", "<cmd>Cr open<cr>", desc = "Open review" },
      { "<leader>rf", "<cmd>Cr files<cr>", desc = "Review files" },
    },
    ---@type CruxConfig
    opts = {
      picker = "auto",
      diff = {
        rename_colors = true,
      },
      thread = {
        open_mode = "float",
      },
      icons = {
        comment = "",
        blocking = "",
        draft = "󰑢",
        resolved = "",
        reply = "",
      },
    },
    config = function(_, opts)
      require("crux").setup(opts)

      -- Suppress lualine winbar on crux diff tabs so crux's own winbar
      -- (file path + revision) is visible. Same pattern as CodeDiff in editor.lua.
      local lualine_ok, lualine = pcall(require, "lualine")
      if lualine_ok and lualine.winbar then
        local orig_winbar = lualine.winbar
        lualine.winbar = function(...)
          if vim.b.crux_diff then
            return nil
          end
          return orig_winbar(...)
        end
      end
    end,
  },
}
