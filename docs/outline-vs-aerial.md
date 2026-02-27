# outline.nvim vs aerial.nvim: Comprehensive Comparison

## Overview

### outline.nvim (hedyhli/outline.nvim)
- **Stars**: 956 ⭐
- **Forks**: 35
- **Description**: Enhanced fork of symbols-outline.nvim with significant improvements
- **Primary Focus**: LSP-powered code outline with modern UI features
- **Neovim Support**: 0.7+ (recommended 0.8+)

### aerial.nvim (stevearc/aerial.nvim)
- **Stars**: 2.2k ⭐
- **Forks**: 112
- **Description**: Mature code outline window for skimming and quick navigation
- **Primary Focus**: Multi-backend outline with extensive treesitter support
- **Neovim Support**: 0.11+ (older versions use nvim-0.x branches)

## Feature Comparison

| Feature | outline.nvim | aerial.nvim |
|---------|-------------|-------------|
| **Symbol Sources** | LSP, CoC, Markdown, Norg, JSX (treesitter), External providers | LSP, Treesitter (60+ languages), Markdown, Asciidoc, Man |
| **Navigation** | Jump, peek, auto-jump, restore location | Jump, next/prev, go to symbol, auto-jump |
| **UI Features** | Auto-width, preview window, live editing, guides, folding | Floating window, nav window (miller columns), guides, folding |
| **Filtering** | Inclusive/exclusive symbol filtering, per-filetype | Symbol kind filtering, per-filetype |
| **Folding** | Auto-fold depth, auto-unfold hovered, tree folding | Manage folds, link tree to folds, fold levels |
| **Breadcrumbs** | Built-in breadcrumb API | No built-in breadcrumbs |
| **Preview** | Floating preview with live editing | No preview window |
| **Live Editing** | ✅ Experimental peek editor | ❌ |
| **Auto-width** | ✅ Dynamic window resizing | ✅ Resize to content |

## Backend Interaction Model

aerial.nvim does **not** merge treesitter and LSP symbols. It picks one backend per buffer
by walking a priority list (configurable per filetype). The first backend that supports the
buffer wins.

Default priority: `lsp → treesitter → markdown → man`

This means:
- **Rust/Python/TypeScript**: LSP is available → aerial uses LSP symbols exclusively
- **Lua**: LSP is available → aerial uses LSP symbols (same lua_ls issues as outline.nvim)
- **No LSP**: falls back to treesitter

To get treesitter symbols for Lua, you must explicitly configure the backend priority:
```lua
backends = {
  _ = { "lsp", "treesitter" },
  lua = { "treesitter", "lsp" },
}
```

## Performance Differences

### outline.nvim
- **Strengths**: Optimized for LSP, efficient symbol updates
- **Considerations**: Preview window can be slow with large files
- **Memory**: Lighter footprint, focused feature set

### aerial.nvim
- **Strengths**: Highly optimized treesitter parsing, efficient for large files
- **Considerations**: Disable limits for files >10k lines or >2MB
- **Memory**: Larger footprint due to extensive language support

## Configuration Complexity

### outline.nvim
- **Complexity**: Moderate
- **Structure**: Well-organized nested configuration
- **Customization**: Extensive UI customization, icon functions
- **Migration**: Provides conversion script from symbols-outline.nvim

### aerial.nvim
- **Complexity**: Higher (more options)
- **Structure**: Comprehensive backend configuration
- **Customization**: Extensive backend and display options
- **Flexibility**: More granular control over behavior

## Maintenance & Community Activity

### outline.nvim
- **Recent Activity**: Very active (commits in Jan 2026)
- **Issues**: 30 open issues
- **Responsiveness**: Active maintainer (hedyhli)
- **Community**: Growing, newer project
- **Latest Release**: v1.2.0 (Jan 31, 2026)

### aerial.nvim
- **Recent Activity**: Very active (established project)
- **Issues**: 67 open issues
- **Responsiveness**: Active maintainer (stevearc)
- **Community**: Large, established community
- **Maturity**: More mature, stable codebase

## Plugin Integrations

### outline.nvim
- **Telescope**: ❌ No built-in integration
- **fzf-lua**: ❌ No built-in integration
- **Lualine**: ✅ Built-in breadcrumb API
- **Icon Sources**: LspKind, custom functions
- **External Providers**: Asciidoc, Treesitter, ctags, Test blocks

### aerial.nvim
- **Telescope**: ✅ Full extension with customization
- **fzf-lua**: ✅ Built-in picker with multi-select
- **fzf**: ✅ Vim function integration
- **Snacks**: ✅ Picker integration
- **Lualine**: ✅ Comprehensive component with options
- **Icon Sources**: LspKind, nvim-web-devicons

## LazyVim Support

### outline.nvim
- **LazyVim Extra**: `extras.editor.outline`
- **Integration**: Well-integrated with LazyVim icons and filtering
- **Keymaps**: Uses arrow keys for up/down navigation
- **Configuration**: Minimal setup required

### aerial.nvim
- **LazyVim Extra**: `extras.editor.aerial`
- **Integration**: Deep integration with LazyVim ecosystem
- **Keymaps**: Standard vim-style navigation
- **Configuration**: More extensive default configuration

## Language Support

### outline.nvim
- **Primary**: LSP-based (supports all LSP languages)
- **Treesitter**: JSX, Markdown, Norg via built-in providers
- **External**: Additional languages via external provider plugins
- **Your Stack**: ✅ Rust, Python, TypeScript, Lua (via LSP)

### aerial.nvim
- **Primary**: 60+ treesitter languages built-in
- **LSP**: Full LSP support (default primary backend)
- **Backend Selection**: One backend per buffer, not merged (see Backend Interaction Model)
- **Your Stack**: ✅ Rust, Python, TypeScript (via LSP); Lua (via treesitter with config override)
- **Coverage**: More comprehensive out-of-the-box language support

## Pros & Cons

### outline.nvim Pros
- ✅ Modern, clean UI with live preview
- ✅ Excellent LSP integration
- ✅ Auto-width and dynamic resizing
- ✅ Built-in breadcrumb API for statuslines
- ✅ Live editing in preview (experimental)
- ✅ Active development with recent features
- ✅ Lighter resource usage

### outline.nvim Cons
- ❌ Limited treesitter support (requires external providers)
- ❌ No telescope/fzf-lua integration
- ❌ Smaller community
- ❌ Preview can be slow with large files
- ❌ Fewer third-party integrations

### aerial.nvim Pros
- ✅ Extensive treesitter language support (60+ languages)
- ✅ Excellent third-party integrations (telescope, fzf-lua, lualine)
- ✅ Mature, stable codebase
- ✅ Miller columns navigation (AerialNav)
- ✅ Large, active community
- ✅ Comprehensive documentation
- ✅ Performance optimizations for large files

### aerial.nvim Cons
- ❌ No preview window
- ❌ No live editing capabilities
- ❌ More complex configuration
- ❌ Higher resource usage
- ❌ Requires newer Neovim (0.11+)

## Recommendation for Your Stack

**For Rust, Python, TypeScript, Lua with LazyVim + fzf-lua + lualine:**

### Choose **aerial.nvim** if you:
- Want extensive treesitter support out-of-the-box
- Need fzf-lua integration for fuzzy symbol search
- Prefer a mature, battle-tested solution
- Want comprehensive lualine integration
- Don't mind the higher complexity

### Choose **outline.nvim** if you:
- Prefer a modern UI with preview capabilities
- Want lighter resource usage
- Like the live editing feature
- Primarily use LSP for symbol information
- Want simpler configuration
- Don't need fuzzy search integration

## Final Recommendation

**aerial.nvim** is the better choice for your specific setup because:

1. **fzf-lua Integration**: Built-in picker support for fuzzy symbol search
2. **Language Support**: Better out-of-the-box support via native treesitter backends for Rust, Python, TypeScript, and Lua
3. **LazyVim Integration**: More mature LazyVim extra with comprehensive defaults
4. **Lualine Component**: More feature-rich lualine integration
5. **Community**: Larger community and ecosystem support
6. **Lua Symbol Quality**: Treesitter backend likely produces better symbol output for Lua than lua_ls alone (which struggles with table-heavy code)

However, if you value modern UI features like live preview and don't need fuzzy search integration, outline.nvim offers a more streamlined experience with innovative features.
