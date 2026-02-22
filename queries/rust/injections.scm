; Full replacement of upstream — `;; extends` is intentionally omitted because
; the upstream `[(line_comment) (block_comment)] @injection.content` injects
; doc comments as "comment", conflicting with our markdown injection below.

; === Doc comments → markdown ===
;
; Inner doc comments (//!) use `injection.combined` so multi-line markdown
; structures (fenced code blocks, lists) parse correctly — these are typically
; contiguous at the top of a file/module.
;
; Outer doc comments (///) are NOT combined. When /// comments are scattered
; across many items with large stretches of Rust code between them,
; `injection.combined` causes the markdown parser to produce block-level nodes
; whose ranges span across the gaps, bleeding markdown highlights into Rust code.
;
; Trade-off: multi-line markdown in /// comments (e.g. fenced code blocks
; spanning multiple /// lines) won't render as markdown. This is acceptable
; because /// blocks are usually short prose, while //! blocks at file/module
; scope are where fenced code examples live.
;
; NOTE on nested injections inside combined doc comments:
; Do NOT add injection rules in queries/markdown/injections.scm that create
; sub-injections (e.g. defaulting untagged code fences to Rust). With
; `injection.combined`, the markdown parser's child nodes (like
; `code_fence_content`) get contiguous ranges that span the full line range,
; but the actual injection content is only the doc_comment fragments. Nested
; sub-parsers see raw buffer content including //! prefixes, causing parse
; errors. This is tracked upstream:
;   - https://github.com/neovim/neovim/issues/21309
;   - https://github.com/neovim/neovim/pull/32549 (fix, merged into main)
; The fix clips combined injection ranges for child parsers but is NOT in
; nvim 0.11.x. Revisit once on a version that includes this fix.
(line_comment
  (inner_doc_comment_marker)
  (doc_comment) @injection.content
  (#set! injection.language "markdown")
  (#set! injection.combined))

(line_comment
  (outer_doc_comment_marker)
  (doc_comment) @injection.content
  (#set! injection.language "markdown"))

; === Non-doc comments → comment (preserves TODO/FIXME highlighting) ===
((line_comment) @injection.content
  (#not-match? @injection.content "^//[/!]")
  (#set! injection.language "comment"))

((block_comment) @injection.content
  (#set! injection.language "comment"))

; === Upstream: macro invocations ===
(macro_invocation
  macro: [
    (scoped_identifier
      name: (_) @_macro_name)
    (identifier) @_macro_name
  ]
  (token_tree) @injection.content
  (#not-any-of? @_macro_name "slint" "html" "json" "xml")
  (#set! injection.language "rust")
  (#set! injection.include-children))

(macro_invocation
  macro: [
    (scoped_identifier
      name: (_) @injection.language)
    (identifier) @injection.language
  ]
  (token_tree) @injection.content
  (#any-of? @injection.language "slint" "html" "json" "xml")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children))

; === Upstream: macro definitions ===
(macro_definition
  (macro_rule
    left: (token_tree_pattern) @injection.content
    (#set! injection.language "rust")))

(macro_definition
  (macro_rule
    right: (token_tree) @injection.content
    (#set! injection.language "rust")))

; === Upstream: Regex ===
(call_expression
  function: (scoped_identifier
    path: (identifier) @_regex
    (#any-of? @_regex "Regex" "RegexBuilder")
    name: (identifier) @_new
    (#eq? @_new "new"))
  arguments: (arguments
    (raw_string_literal
      (string_content) @injection.content))
  (#set! injection.language "regex"))

(call_expression
  function: (scoped_identifier
    path: (scoped_identifier
      (identifier) @_regex
      (#any-of? @_regex "Regex" "RegexBuilder") .)
    name: (identifier) @_new
    (#eq? @_new "new"))
  arguments: (arguments
    (raw_string_literal
      (string_content) @injection.content))
  (#set! injection.language "regex"))

(call_expression
  function: (scoped_identifier
    path: (identifier) @_regex
    (#any-of? @_regex "RegexSet" "RegexSetBuilder")
    name: (identifier) @_new
    (#eq? @_new "new"))
  arguments: (arguments
    (array_expression
      (raw_string_literal
        (string_content) @injection.content)))
  (#set! injection.language "regex"))

(call_expression
  function: (scoped_identifier
    path: (scoped_identifier
      (identifier) @_regex
      (#any-of? @_regex "RegexSet" "RegexSetBuilder") .)
    name: (identifier) @_new
    (#eq? @_new "new"))
  arguments: (arguments
    (array_expression
      (raw_string_literal
        (string_content) @injection.content)))
  (#set! injection.language "regex"))

; === Upstream: re2c ===
((block_comment) @injection.content
  (#match? @injection.content "/\\*!([a-zA-Z]+:)?re2c")
  (#set! injection.language "re2c"))

; === Custom: language-tagged raw string literals ===
((line_comment) @injection.language
  .
  [(raw_string_literal
    (string_content) @injection.content)]
  (#gsub! @injection.language "//%s*([%w%p]+)%s*" "%1")
  (#set! injection.combined))

((block_comment) @injection.language
  .
  [(raw_string_literal
    (string_content) @injection.content)]
  (#gsub! @injection.language "/%*%s*([%w%p]+)%s*%*/" "%1")
  (#set! injection.combined))
