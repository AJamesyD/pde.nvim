if not require("util").amazon.is_amazon_machine() then
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
              local primary = MyUtils.amazon.brazil_root(fname)
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
}
