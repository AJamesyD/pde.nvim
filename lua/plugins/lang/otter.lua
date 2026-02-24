-- LSP features (completion, hover, diagnostics, go-to-definition) inside
-- treesitter-injected code blocks. otter-ls attaches as a regular language
-- server, so blink.cmp and conform's `injected` formatter work out of the box.
-- See: https://github.com/jmbuhr/otter.nvim

local otter_fts = { "markdown", "nix" }

return {
  {
    "jmbuhr/otter.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = otter_fts,
    opts = {
      handle_leading_whitespace = true,
    },
    config = function(_, opts)
      local otter = require("otter")
      otter.setup(opts)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = otter_fts,
        group = vim.api.nvim_create_augroup("OtterActivate", { clear = true }),
        callback = function()
          otter.activate()
        end,
      })
    end,
  },
}
