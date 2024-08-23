local function bemol()
  local bemol_dir = vim.fs.find({ ".bemol" }, { upward = true, type = "directory" })[1]
  local ws_folders_lsp = {}
  if bemol_dir then
    -- Disable autoformatting in Brazil projects
    vim.g.autoformat = false
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

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        url = "angaidan@git.amazon.com:pkg/NinjaHooks",
        cond = vim.g.amazon,
        branch = "mainline",
        lazy = false,
        init = function()
          require("lazyvim.util").lsp.on_attach(function()
            bemol()
          end)
        end,
        config = function(plugin)
          vim.opt.rtp:prepend(plugin.dir .. "/configuration/vim/amazon/brazil-config")
          -- Make my own filetype thing to override neovim applying ".conf" file type.
          -- You may or may not need this depending on your setup.
          vim.filetype.add({
            filename = {
              ["Config"] = function()
                vim.b.brazil_package_Config = 1
                return "brazil-config"
              end,
            },
          })
        end,
      },
    },
    opts = function(_, opts)
      if vim.g.amazon then
        local lspconfig = require("lspconfig")
        local configs = require("lspconfig.configs")
        configs.barium = {
          default_config = {
            cmd = { "barium" },
            filetypes = { "brazil-config" },
            root_dir = function(fname)
              return lspconfig.util.find_git_ancestor(fname)
            end,
            settings = {},
          },
        }
        lspconfig.barium.setup({})
      end
      return opts
    end,
  },
}
