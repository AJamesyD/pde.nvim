# Otter Preambles Plan

## Research: lazy.nvim `opts` handling

lazy.nvim's plugin spec supports `opts` as either a table or a function:

- **Table**: lazy.nvim deep-merges `opts` tables from all specs for the same
  plugin (across files, extras, etc.) using `vim.tbl_deep_extend`. The merged
  result is passed to `config(_, opts)`.
- **Function** `opts = function(_, opts)`: receives the already-merged opts
  table, lets you mutate or return a new one. Needed when you must merge lists
  (which `tbl_deep_extend` overwrites by index) or compute values dynamically.

When `config` is not specified, lazy.nvim calls `require(plugin).setup(opts)`
automatically. When `config` is a function, it receives the merged opts and
the plugin is responsible for calling setup itself.

## Current state

`lang/otter.lua` already uses the correct pattern:

```lua
opts = {
  buffers = {
    preambles = { bash = { "#!/usr/bin/env bash" } },
    ignore_pattern = { bash = "^#!" },
  },
},
config = function(_, opts)
  local otter = require("otter")
  otter.setup(opts)
  -- ... RPC patch ...
end,
```

`opts` is a plain table, `config` receives the merged result and calls
`setup(opts)`. This is fine — no need to switch to `opts = function` because:

- `preambles` is a `table<string, string[]>` keyed by language name.
- `tbl_deep_extend` merges dict-like tables correctly; we're only adding new
  keys, not appending to an existing list.
- No other spec contributes otter opts, so there's nothing to conflict with.

The `opts = function` pattern (as seen in `treesitter.lua`, `rustaceanvim`)
is needed when merging list-valued fields like `ensure_installed` where
`tbl_deep_extend` would clobber rather than append. That doesn't apply here.

## Languages to add preambles for

Based on lang plugins, ftplugin files, treesitter config, and otter_fts
(`markdown`, `nix`), these are the languages likely to appear in code blocks:

| Language   | Evidence                              | Preamble purpose                                    |
|------------|---------------------------------------|-----------------------------------------------------|
| bash       | ftplugin/sh.lua, already configured   | Shebang (already done)                              |
| python     | lang/python.lua, ftplugin/python.lua  | Common stdlib + typing imports                      |
| lua        | lang/lua.lua, ftplugin/lua.lua        | Neovim globals (`vim`) are already in scope via lua_ls, but a `local M = {}` or similar won't help — skip or add minimal |
| rust       | lang/rust.lua, ftplugin/rust.lua      | Common std preludes are automatic; `use` for collections/io |
| typescript | User's example in conversation        | Common type imports                                 |
| javascript | Sibling to typescript                 | Minimal — most snippets are self-contained          |
| nix        | lang/nix.lua, otter_ft                | Nix has implicit scope; no preamble needed          |
| sql        | treesitter ensure_installed           | Dialect-dependent; skip                             |
| java       | lang/java.lua                         | Common imports (util, io, stream)                   |

### Decisions

- **bash**: Keep existing shebang + ignore_pattern. No change.
- **python**: Add `from __future__ import annotations`, common stdlib, typing.
  Also keep otter's default `ignore_pattern` for ipython magic (`^(%s*[%%!].*)`).
- **lua**: Add `---@diagnostic disable` to suppress noisy warnings in snippets
  (undefined-global for `vim`, etc.). lua_ls already knows about `vim` if
  configured, but snippets often reference locals from outside the block.
- **rust**: Rust's std prelude covers most basics. Add `use std::collections::*;`
  and `use std::io::*;` for the common cases snippets need.
- **typescript**: Add `export {};` (makes it a module) and `declare` stubs for
  common globals that snippets reference without importing.
- **javascript**: Same idea as typescript but lighter.
- **java**: Add common `java.util.*` and `java.io.*` imports.
- **nix**, **sql**: Skip — nix has implicit scope, sql is dialect-dependent.

## Implementation

Isolate each language's preamble in its own `lua/plugins/lang/<lang>.lua` file
using a separate `jmbuhr/otter.nvim` spec with `optional = true`. lazy.nvim
deep-merges all specs for the same plugin, so each file just contributes its
key to `opts.buffers.preambles`. The `optional = true` flag means the spec is
silently ignored if otter.nvim isn't installed/enabled — the preamble config
only activates when the base otter spec (in `lang/otter.lua`) is present.

### Base spec (`lang/otter.lua`)

Keep as-is. It owns `ft`, `dependencies`, `config`, `handle_leading_whitespace`,
and the bash preamble + ignore_pattern (bash is a cross-language concern for
shell blocks in markdown, not tied to a dedicated lang file).

### Per-language specs (new otter entries in existing files)

Each file gets an additional entry in its returned table:

| File              | Preamble key   | Notes                                          |
|-------------------|----------------|-------------------------------------------------|
| `lang/python.lua` | `python`       | typing + common stdlib; add `ignore_pattern`    |
| `lang/lua.lua`    | `lua`          | Suppress noisy diagnostics for snippet context  |
| `lang/rust.lua`   | `rust`         | Common std imports beyond the prelude           |
| `lang/java.lua`   | `java`         | `java.util.*`, `java.io.*`                      |

### New files

| File                   | Preamble key   | Notes                                     |
|------------------------|----------------|-------------------------------------------|
| `lang/typescript.lua`  | `typescript`   | Module declaration + common type stubs    |
| `lang/javascript.lua`  | `javascript`   | Lighter version of typescript preamble    |

### Pattern

Each addition looks like:

```lua
{
  "jmbuhr/otter.nvim",
  optional = true,
  opts = {
    buffers = {
      preambles = {
        <lang> = { ... },
      },
    },
  },
},
```

No `opts = function` needed — we're only adding new dict keys, not merging
lists.
