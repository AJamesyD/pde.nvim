vim.diagnostic.config({
  float = { border = "rounded" },
})

require("snacks")
  .toggle({
    name = "Lensline",
    get = function()
      return require("lensline").is_visible()
    end,
    set = function(_)
      require("lensline").toggle_view()
    end,
    notify = false,
  })
  :map("<leader>ul")

return {
  -- Reconfigure LazyVim defaults
  {
    "neovim/nvim-lspconfig",
    ---@type PluginLspOpts
    opts = {
      ---@type vim.diagnostic.Opts
      diagnostics = {
        virtual_text = { prefix = "icons" },
      },
      ---@type lsp.CodeLensOptions
      codelens = {
        enabled = true,
      },
    },
  },
  {
    "mason-org/mason.nvim",
    ---@type MasonSettings
    opts = {
      PATH = "append",
      max_concurrent_installers = 10,
      ui = {
        border = "rounded",
      },
    },
  },

  -- Other
  {
    "oribarilan/lensline.nvim",
    cmd = {
      "LenslineEnable",
      "LenslineDisable",
      "LenslineToggleEngine",
      "LenslineToggle",
      "LenslineShow",
      "LenslineHide",
      "LenslineToggleView",
    },
    branch = "release/2.x",
    event = { "LspAttach", "BufWritePost" },
    opts = {},
    config = true,
  },
}
