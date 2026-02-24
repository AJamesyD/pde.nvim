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

      -- otter-ls's RPC `request` doesn't return (true, request_id), so
      -- snacks picker can't track it and fires "Finder yielded after done"
      -- when the async response arrives late. Wrap the method to return
      -- proper tracking values.  https://github.com/jmbuhr/otter.nvim/issues/XXX
      local function patch_otter_rpc(client)
        local rpc = rawget(client, "rpc") or client._rpc
        if not rpc or rpc._otter_patched then
          return
        end
        local orig = rpc.request
        local next_id = 0
        rpc.request = function(method, params, handler, ...)
          next_id = next_id + 1
          local id = next_id
          orig(method, params, handler, ...)
          return true, id
        end
        rpc._otter_patched = true
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = otter_fts,
        group = vim.api.nvim_create_augroup("OtterActivate", { clear = true }),
        callback = function()
          otter.activate()
          -- patch after activate so the client exists
          vim.schedule(function()
            for _, c in ipairs(vim.lsp.get_clients({ name = "otter-ls" })) do
              patch_otter_rpc(c)
            end
          end)
        end,
      })
    end,
  },
}
