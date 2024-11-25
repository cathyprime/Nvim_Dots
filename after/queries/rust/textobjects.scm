;; extends

(generic_type
  type: (_)) @type.outer

(generic_type
  type: (_)
  type_arguments: (type_arguments
                    (_) @_start
                    (_)? @_end
                    (#make-range! "type.inner" @_start @_end))) @type.outer
