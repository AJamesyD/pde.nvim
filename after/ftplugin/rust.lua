-- Clear LSP semantic token highlights for comments so tree-sitter
-- injections (markdown → toml/rust/etc.) can show through in doc comments.
-- rust-analyzer applies these at priority 125-127, overriding injections (~102).
vim.api.nvim_set_hl(0, "@lsp.type.comment.rust", {})
vim.api.nvim_set_hl(0, "@lsp.mod.documentation.rust", {})
vim.api.nvim_set_hl(0, "@lsp.typemod.comment.documentation.rust", {})

-- Decorate doc comment code blocks:
-- 1. Dim rustdoc hidden lines (# prefix) as comments, using the markdown
--    AST to distinguish them from headings
-- 2. Clear broken inner-rust-parser highlights on ```rust blocks (the
--    combined injection's rectangular ranges cause the inner parser to see
--    the //!//// prefix on non-first lines, misparsing them as comments)
-- Spell suppression is handled by queries/markdown/highlights.scm instead.
local code_ns = vim.api.nvim_create_namespace("rustdoc_code_blocks")

local function update_code_blocks()
  vim.api.nvim_buf_clear_namespace(0, code_ns, 0, -1)
  local ok, parser = pcall(vim.treesitter.get_parser, 0)
  if not ok or not parser then return end
  parser:parse(true)
  local md = parser:children().markdown
  if not md then return end
  md:parse(true)
  local query = vim.treesitter.query.parse("markdown", [[
    (fenced_code_block
      (info_string (language) @lang)?
      (code_fence_content) @content)
  ]])
  for _, tree in ipairs(md:trees()) do
    for id, node, _, _ in query:iter_captures(tree:root(), 0) do
      if query.captures[id] ~= "content" then goto next_capture end
      local sr, _, er = node:range()
      -- Check if this block is ```rust (broken inner parser needs override)
      local is_rust = false
      local parent = node:parent()
      if parent then
        for child in parent:iter_children() do
          if child:type() == "info_string" then
            is_rust = vim.treesitter.get_node_text(child, 0):match("^rust") ~= nil
            break
          end
        end
      end
      for row = sr, er - 1 do
        local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
        local content = line:match("^%s*///(.*)") or line:match("^%s*//!(.*)")
        if not content then goto next_row end
        if content:match("^%s*# ") or content:match("^%s*#$") then
          vim.api.nvim_buf_set_extmark(0, code_ns, row, 0, {
            end_row = row, end_col = #line,
            hl_group = "@comment", priority = 200,
          })
        elseif is_rust then
          vim.api.nvim_buf_set_extmark(0, code_ns, row, #line - #content, {
            end_row = row, end_col = #line,
            hl_group = "@markup.raw.block.markdown", priority = 103,
          })
        end
        ::next_row::
      end
      ::next_capture::
    end
  end
end

vim.defer_fn(update_code_blocks, 100)
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  buffer = 0, callback = update_code_blocks,
})

local bufnr = vim.api.nvim_get_current_buf()
local function settings_updater(settings)
  vim.g.clippy_level = (vim.g.clippy_level + 1) % 4
  local extra_args = {}
  local message = ""
  if vim.g.clippy_level == 0 then
    extra_args = {
      "--no-deps",
    }
    message = "clippy lints: default only"
  elseif vim.g.clippy_level == 1 then
    extra_args = {
      "--no-deps",
      "--",
      "-Wclippy::cargo",
    }
    message = "clippy lints: cargo, default"
  elseif vim.g.clippy_level == 2 then
    extra_args = {
      "--no-deps",
      "--",
      "-Wclippy::nursery",
      "-Wclippy::cargo",
    }
    message = "clippy lints: nursery, cargo, default"
  elseif vim.g.clippy_level == 3 then
    extra_args = {
      "--no-deps",
      "--",
      "-Wclippy::pedantic",
      "-Wclippy::nursery",
      "-Wclippy::cargo",
    }
    message = "clippy lints: pedantic, nursery, cargo, default"
  end

  vim.notify(message)

  settings["rust-analyzer"].check.extraArgs = extra_args
  return settings
end

vim.keymap.set("n", "<leader>cD", function()
  local client_filter = {
    bufnr = bufnr,
    name = "rust-analyzer",
  }
  MyUtils.reload_lsp_setting({
    client_filter = client_filter,
    settings_updater = settings_updater,
    restart_cmd = "RustAnalyzer reloadSettings",
  })
end, { desc = "Cycle Diagnostic Level", buffer = bufnr })
