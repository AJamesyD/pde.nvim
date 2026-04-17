local M = {}

-- LSP CompletionItemKind values that should sink below everything else.
M.DEMOTED = {
  -- Text
  [1] = true,
  -- Keyword
  [14] = true,
  -- Snippet
  [15] = true,
}

function M.compare(a, b)
  local da = M.DEMOTED[a.kind] or false
  local db = M.DEMOTED[b.kind] or false
  if da ~= db then return db end
end

return M
