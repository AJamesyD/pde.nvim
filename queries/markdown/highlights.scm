;; extends

; Disable spell checking inside fenced code blocks.  In Rust doc comments the
; `@spell` capture on `line_comment` (pri 102) would otherwise leak into code;
; this @nospell at 103 overrides it.  Also a sensible default for plain markdown.
((code_fence_content) @nospell (#set! priority 103))
