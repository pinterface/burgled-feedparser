;;;; burgled-feedparser 

(defsystem "burgled-feedparser"
  :description "A Lisp interface to Python's Universal Feed Parser."
  :author "pinterface <pix@kepibu.org>"
  :license "MIT"
  :depends-on ("burgled-batteries" "alexandria")
  :serial t
  :components ((:file "package")
               (:file "api")))
