local util = require("util")

if not util.amazon.is_amazon_machine() then
  return {}
end

vim.filetype.add({
  filename = {
    ["Config"] = function()
      vim.b.brazil_package_Config = 1
      return "brazil-config"
    end,
  },
})

return {
  -- Reconfigure LazyVim defaults
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      if require("util").amazon.is_amazon_machine() then
        local lspconfig = require("lspconfig")
        local configs = require("lspconfig.configs")
        ---@type lspconfig.Config
        configs.barium = {
          default_config = {
            cmd = { "barium" },
            filetypes = { "brazil-config" },
            root_dir = function(fname)
              local primary = util.amazon.amazon_root(fname, "brazil")
              local fallback = vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
              return primary or fallback
            end,
            settings = {},
          },
        }
        lspconfig.barium.setup({})
      end
      return opts
    end,
  },
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
  {
    url = "angaidan@git.amazon.com:pkg/NinjaHooks",
    branch = "mainline",
    cond = require("util").amazon.is_amazon_machine(),
    dependencies = {},
    lazy = false,
    config = function(plugin)
      local nvim_conf_dir = "~/.config/nvim"
      vim.opt.rtp:remove(nvim_conf_dir)
      vim.opt.rtp:prepend(plugin.dir .. "/configuration/vim")
      -- NOTE: Make sure ~/.config/nvim is always first in runtime path (for spell, etc)
      vim.opt.rtp:prepend(nvim_conf_dir)
    end,
  },
  {
    url = "angaidan@git.amazon.com:pkg/VimBrazilConfig",
    branch = "mainline",
    cond = require("util").amazon.is_amazon_machine(),
    lazy = false,
    config = function(plugin)
      local nvim_conf_dir = "~/.config/nvim"
      vim.opt.rtp:remove(nvim_conf_dir)
      vim.opt.rtp:prepend(plugin.dir)
      -- NOTE: Make sure ~/.config/nvim is always first in runtime path (for spell, etc)
      vim.opt.rtp:prepend(nvim_conf_dir)
    end,
  },
  {
    url = "angaidan@git.amazon.com:pkg/VimIon",
    branch = "mainline",
    cond = require("util").amazon.is_amazon_machine(),
    lazy = false,
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
