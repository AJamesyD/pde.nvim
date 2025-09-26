vim.diagnostic.config({
  float = { border = "rounded" },
})

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
    "jmbuhr/otter.nvim",
    event = "LazyFile",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = function(_, opts)
      vim.api.nvim_create_autocmd({ "FileType" }, {
        desc = "otter.nvim setup",
        pattern = { "markdown", "nix" },
        callback = function(event)
          local bufnr = event.buf

          local is_relevant_file = vim.b[bufnr].is_relevant_file
          local is_relevant_file_set_callback = function()
            is_relevant_file = vim.b[bufnr].is_relevant_file
            return type(is_relevant_file) == "boolean"
          end

          local ts_active_callback = function()
            return vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()]
          end

          if vim.wait(500, is_relevant_file_set_callback, 50) then
            if not is_relevant_file then
              return
            end
          end

          if vim.wait(2000, ts_active_callback, 200) then
            require("otter").activate()
          else
            vim.notify("Treesitter not active, could not setup otter.nvim", vim.log.levels.WARN)
          end
        end,
      })

      local overrides = {
        lsp = {
          diagnostic_update_events = { "BufWritePost", "InsertLeave" },
          root_dir = function(_, bufnr)
            return LazyVim.root.get({ buf = bufnr or 0 }) or LazyVim.root.cwd()
          end,
        },
        buffers = {
          set_filetype = true,
          -- write_to_disk = true,
        },
        handle_leading_whitespace = true,
      }

      opts = vim.tbl_deep_extend("force", opts, overrides)
      return opts
    end,
  },
  {
    "oribarilan/lensline.nvim",
    branch = "release/1.x",
    event = "LspAttach",
    opts = {},
    config = true,
  },
}
