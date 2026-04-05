; =============================================================================
; D language indent queries
;
; The built-in nvim-treesitter query is broken: it captures both
; scope_statement+function_body AND block_statement as @indent.begin, causing
; double-indentation on every braced block. This replaces it entirely.
;
; Known limitation: `extern(C) @nogc nothrow { }` attribute blocks have their
; { } as bare anonymous children of module_def (grammar design issue), so their
; contents cannot be auto-indented. Use `extern(C):` (colon form) instead.
; =============================================================================

; === MANIFEST CONSTANTS (enum T name = ...) ===
((manifest_declarator) @indent.begin
 (#set! indent.start_at_same_line true))

; === TEMPLATE CONSTRAINTS ===
((struct_declaration (constraint) @indent.begin)
 (#set! indent.start_at_same_line true)
 (#set! indent.immediate true))

; === BRACED BLOCKS ===
(block_statement) @indent.begin
(block_statement "}" @indent.end)

(aggregate_body) @indent.begin
(aggregate_body "}" @indent.end)

(enum_declaration) @indent.begin
(enum_declaration "}" @indent.end)
(anonymous_enum_declaration) @indent.begin
(anonymous_enum_declaration "}" @indent.end)

((conditional_declaration "{") @indent.begin)
(conditional_declaration "}" @indent.end)

(case_statement) @indent.begin

; === SINGLE-STATEMENT BODIES (no braces) ===
((if_statement
  (scope_statement
    (_) @_body)) @indent.begin
 (#not-kind-eq? @_body "block_statement" "if_statement"))

((foreach_statement
  (scope_statement
    (_) @_body)) @indent.begin
 (#not-kind-eq? @_body "block_statement"))

((while_statement
  (scope_statement
    (_) @_body)) @indent.begin
 (#not-kind-eq? @_body "block_statement"))

((for_statement
  (scope_statement
    (_) @_body)) @indent.begin
 (#not-kind-eq? @_body "block_statement"))

; === BRANCH TOKENS ===
[
  "}"
  "]"
  ")"
  (case)
  (default)
] @indent.branch

; === PARAMETER / ARGUMENT ALIGNMENT ===
([
  (parameters)
  (named_arguments)
  (template_parameters)
] @indent.align
  (#set! indent.open_delimiter "(")
  (#set! indent.close_delimiter ")"))

; === MISC ===
(comment) @indent.auto

[
  (directive)
  (shebang)
] @indent.zero
