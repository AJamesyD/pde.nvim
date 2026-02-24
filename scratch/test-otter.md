# Otter.nvim Test File

Test LSP features inside injected code blocks.

otter-ls is a regular LSP server, so blink.cmp's `lsp` source and
conform's `injected` formatter work without extra config. Treesitter
injection queries are used as-is.

## Lua

```lua
local M = {}

function M.greet(name)
  return "Hello, " .. name
end

-- Try: hover on `vim.api`, completion after `vim.`, gd on M.greet
vim.api.nvim_buf_set_lines(0, 0, -1, false, { M.greet("world") })
```

## Python

```python
import os

def hello(name: str) -> str:
    return f"Hello, {name}"

# Try: hover on `os.path`, completion after `os.`, diagnostics on typos
result = os.path.join("/tmp", hello("world"))
```

## Bash

```bash
#!/usr/bin/env bash
set -euo pipefail

greet() {
	local name="$1"
	echo "Hello, ${name}"
}

greet "world"
```

## Upstream Tests

otter.nvim ships its own test suite under `tests/` (plenary-based).
Run from the plugin root (`~/.local/share/nvim/lazy/otter.nvim`):

```bash
./tests/run                        # all specs
./tests/run tests/core/extraction_spec.lua  # just extraction
```

Spec files in `tests/core/`:

- `extraction_spec.lua` — code chunk extraction across filetypes (md, qmd, org, norg, nix, rs, ts, lua), indentation preservation, HTML embedded JS/CSS, otter buffer sync
- `lsp_spec.lua` — LSP position translation (main ↔ otter), leading offset, completion/hover range adjustment, blink.cmp integration
- `otter_spec.lua` — module loading, public API surface (`activate`, `deactivate`, `sync_raft`, `export`), keeper internals, config merging, helper functions
- `init_spec.lua` — test environment sanity check

Example fixtures live in `tests/examples/` (`.md`, `.qmd`, `.org`, `.norg`, `.nix`, `.rs`, `.ts`, `.lua`).

## Verification Checklist

- [ ] `:LspInfo` shows `otter-ls` attached
- [ ] Completion works inside code blocks
- [ ] Hover (`K`) shows docs on symbols
- [ ] Go-to-definition (`gd`) works
- [ ] Diagnostics appear for errors
- [ ] Open a nix file with embedded bash/lua, repeat above
