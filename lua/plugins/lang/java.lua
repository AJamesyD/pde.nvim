return {
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      ---@type lspconfig.Config
      local overrides = {
        on_attach = MyUtils.amazon.bemol,

        settings = {
          java = {
            references = {
              includeDecompiledSources = true,
            },
            eclipse = {
              downloadSources = true,
            },
            maven = {
              downloadSources = true,
            },
            sources = {
              organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
              },
            },
          },
        },

        -- Default patterns + ".bemol"
        root_dir = require("lspconfig.util").root_pattern({ ".bemol", ".git", "mvnw", "gradlew" }),
      }
      opts = vim.tbl_deep_extend("force", opts, overrides)

      return opts
    end,
  },
}
