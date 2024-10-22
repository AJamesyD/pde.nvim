local function bemol()
  local bemol_dir = vim.fs.find({ ".bemol" }, { upward = true, type = "directory" })[1]
  local ws_folders_lsp = {}
  if bemol_dir then
    -- Often want to disable autoformatting in Brazil projects
    -- vim.g.autoformat = false
    local file = io.open(bemol_dir .. "/ws_root_folders", "r")
    if file then
      for line in file:lines() do
        table.insert(ws_folders_lsp, line)
      end
      file:close()
    end
  end

  for _, line in ipairs(ws_folders_lsp) do
    vim.lsp.buf.add_workspace_folder(line)
  end
end

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
  desc = "Run bemol when entering compatible Amazon project",
  ---@param event vim.api.create_autocmd.callback.args
  callback = function(event)
    local bufnr = event.buf
    local filepath = vim.api.nvim_buf_get_name(bufnr)
    local filetype = vim.bo[event.buf].filetype
    local brazil_root = require("lspconfig.util").root_pattern("Config")(filepath)

    if brazil_root ~= nil and filetype == "sh" then
      vim.b.autoformat = false
      vim.bo[event.buf].expandtab = false
    end

    -- TODO: Only run on supported languages https://w.amazon.com/bin/view/Bemol#HPluginFeatures
    if brazil_root ~= nil then
      bemol()
    end
  end,
})

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        url = "angaidan@git.amazon.com:pkg/NinjaHooks",
        branch = "mainline",
        cond = require("util").is_amazon(),
        lazy = false,
        config = function(plugin)
          local nvim_conf_dir = "~/.config/nvim"
          vim.opt.rtp:remove(nvim_conf_dir)
          vim.opt.rtp:prepend(plugin.dir .. "/configuration/vim/amazon/brazil-config")
          -- NOTE: Make sure ~/.config/nvim is always first in runtime path (for spell, etc)
          vim.opt.rtp:prepend(nvim_conf_dir)
        end,
      },
    },
    opts = function(_, opts)
      if MyUtils.is_amazon() then
        local lspconfig = require("lspconfig")
        local configs = require("lspconfig.configs")
        ---@type lspconfig.Config
        configs.barium = {
          default_config = {
            cmd = { "barium" },
            filetypes = { "brazil-config" },
            root_dir = function(fname)
              return lspconfig.util.find_git_ancestor(fname) or lspconfig.util.root_pattern("Config")
            end,
            settings = {},
          },
          on_attach = bemol,
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
}
