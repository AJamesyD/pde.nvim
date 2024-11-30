-- https://github.com/stevearc/overseer.nvim/blob/10ee48ff96c8d1049efb278ea4c8cf9f3b0e4326/doc/guides.md#custom-components
return {
  desc = "Setup up LSP with bemol discovered workspaces",
  constructor = function(params)
    return {
      ---@param code number The process exit code
      on_exit = function(self, task, code)
        if code ~= 0 then
          vim.notify("bemol command failed", vim.log.levels.ERROR)
          return
        end

        local bemol_dir = vim.fs.find({ ".bemol" }, { upward = true, type = "directory" })[1]
        if not bemol_dir then
          vim.notify(".bemol failed to be generated", vim.log.levels.ERROR)
          return
        end

        local ws_folders_lsp = {}
        local file = io.open(bemol_dir .. "/ws_root_folders", "r")
        if file then
          for line in file:lines() do
            table.insert(ws_folders_lsp, line)
          end
          file:close()
        end

        for _, line in ipairs(ws_folders_lsp) do
          vim.lsp.buf.add_workspace_folder(line)
        end
      end,
    }
  end,
}
