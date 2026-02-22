;; extends

; Disable spell checking inside fenced code blocks.  In Rust doc comments the
; `@spell` capture on `line_comment` (pri 102) would otherwise leak into code;
; this @nospell at 103 overrides it.  Also a sensible default for plain markdown.
;
; See also: queries/rust/highlights.scm for the @nospell/@spell priority chain
; that prevents spell-checking on Rust code between combined doc comments.
((code_fence_content) @nospell (#set! priority 103))
