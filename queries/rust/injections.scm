;; extends

((block_comment) @injection.content
  (#set! injection.language "comment"))

((line_comment) @injection.content
  (#set! injection.language "comment"))

((block_comment) @injection.language
  . ; this is to make sure only adjacent comments are accounted for the injections
  [
    (raw_string_literal
      (string_content) @injection.content)
  ]
  (#gsub! @injection.language "/%*%s*([%w%p]+)%s*%*/" "%1")
  (#set! injection.combined))

((line_comment) @injection.language
  . ; this is to make sure only adjacent comments are accounted for the injections
  [
    (raw_string_literal
      (string_content) @injection.content)
  ]
  (#gsub! @injection.language "//%s*([%w%p]+)%s*" "%1")
  (#set! injection.combined))
