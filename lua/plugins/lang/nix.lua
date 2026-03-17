-- Use builtins.getEnv to avoid hardcoding the home directory path.
-- nixd evaluates in impure mode so getEnv and getFlake work.
local nix_flake = '(builtins.getFlake (builtins.getEnv "HOME" + "/.config/nix"))'

return {
  -- Reconfigure LazyVim defaults
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      servers = {
        -- Disable nil_ls: nixd covers all its features (diagnostics,
        -- completion, goto-def) and additionally supports option/nixpkgs
        -- completion. Running both causes duplicate diagnostics.
        nil_ls = { enabled = false },
        ---@type vim.lsp.ClientConfig
        ---@diagnostic disable-next-line: missing-fields
        nixd = {
          settings = {
            nixd = {
              nixpkgs = {
                expr = ("import %s.inputs.nixpkgs { }"):format(nix_flake),
              },
              -- "options" (not "opts") is the correct nixd setting key.
              -- Each entry maps a module system name to an expression that
              -- evaluates to its option declarations.
              options = {
                ["flake-parts"] = {
                  expr = ("%s.debug.options"):format(nix_flake),
                },
                ["flake-parts=ps"] = {
                  expr = ("%s.currentSystem.options"):format(nix_flake),
                },
              },
              diagnostic = {
                suppress = { "sema-extra-with" },
              },
            },
          },
          on_attach = function(client, bufnr)
            -- TODO: Re-enable when semantic highlighting is better
            client.server_capabilities.semanticTokensProvider = nil
          end,
        },
      },
    },
  },
}
