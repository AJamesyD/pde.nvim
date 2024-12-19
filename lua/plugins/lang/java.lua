return {
  -- Reconfigure LazyVim extras
  {
    "mfussenegger/nvim-jdtls",
    optional = true,
    opts = function(_, opts)
      ---@type lspconfig.Config
      local overrides = {
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
