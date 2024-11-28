-- Make my own filetype thing to override neovim applying ".conf" file type.
-- You may or may not need this depending on your setup.
vim.filetype.add({
  extension = {
    ion = "ion",
  },
  filename = {
    ["Config"] = function()
      vim.b.brazil_package_Config = 1
      return "brazil-config"
    end,
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "Amazon project setup",
  callback = function(event)
    local bufnr = event.buf
    local filepath = vim.api.nvim_buf_get_name(bufnr)

    local is_brazil_proj = MyUtils.amazon.brazil_root(filepath)
    local is_peru_proj = MyUtils.amazon.peru_root(filepath)

    if is_brazil_proj then
      -- Often want to disable autoformatting in Brazil projects
      vim.g.autoformat = false
      vim.bo[event.buf].expandtab = false
    end

    if MyUtils.amazon.is_bemol_proj(bufnr) then
      MyUtils.amazon.bemol()
    end
  end,
})

return {
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
              local primary = lspconfig.util.root_pattern("Config")(fname)
              local fallback = lspconfig.util.find_git_ancestor(fname)
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
    optional = true,
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
  {
    url = "angaidan@git.amazon.com:pkg/NinjaHooks",
    branch = "mainline",
    cond = require("util").amazon.is_amazon(),
    lazy = false,
    config = function(plugin)
      local nvim_conf_dir = "~/.config/nvim"
      vim.opt.rtp:remove(nvim_conf_dir)
      vim.opt.rtp:prepend(plugin.dir .. "/configuration/vim/amazon/brazil-config")
      -- NOTE: Make sure ~/.config/nvim is always first in runtime path (for spell, etc)
      vim.opt.rtp:prepend(nvim_conf_dir)
    end,
  },
}
