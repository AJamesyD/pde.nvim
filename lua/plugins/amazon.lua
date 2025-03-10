if not require("util").amazon.is_amazon() then
  return {}
end

return {
  -- Reconfigure LazyVim defaults
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      if require("util").amazon.is_amazon() then
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

  -- Other
  {
    url = "angaidan@git.amazon.com:pkg/NinjaHooks",
    branch = "mainline",
    cond = require("util").amazon.is_amazon(),
    lazy = false,
    config = function(plugin)
      vim.filetype.add({
        filename = {
          ["Config"] = function()
            vim.b.brazil_package_Config = 1
            return "brazil-config"
          end,
        },
      })

      local nvim_conf_dir = "~/.config/nvim"
      vim.opt.rtp:remove(nvim_conf_dir)
      vim.opt.rtp:prepend(plugin.dir .. "/configuration/vim/amazon/brazil-config")
      -- NOTE: Make sure ~/.config/nvim is always first in runtime path (for spell, etc)
      vim.opt.rtp:prepend(nvim_conf_dir)
    end,
  },
  {
    url = "angaidan@git.amazon.com:pkg/VimIon",
    branch = "mainline",
    cond = require("util").amazon.is_amazon(),
    lazy = false,
  },
}
