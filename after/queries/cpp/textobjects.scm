;; extends

(qualified_identifier
 name: (template_type
     arguments: (template_argument_list
         (_) @_start
         (_)? @_end
         (#make-range! "type.inner" @_start @_end )))) @type.outer

(qualified_identifier
  name: (qualified_identifier
          scope: (template_type
                   arguments: (_) @template.inner))) @template.outer
