;; extends

(preproc_def
  name: (identifier) @constant.macro)

((null) @nullptr
        (#match? @nullptr "nullptr")
        (#set! "priority" 110) ) @keyword.nullptr
