;; extends

; `injection.combined` merges ALL doc comments into one markdown document.
; The markdown parser produces `inline` nodes spanning across non-comment code,
; and `(inline) @spell` from markdown highlights leaks spell-checking onto code.
; Fix: blanket @nospell at priority 101 (ties with markdown's @spell — @nospell
; wins ties), then re-enable @spell on actual comments at priority 102.
((source_file) @nospell (#set! priority 101))
([(line_comment) (block_comment)] @spell (#set! priority 102))
