(defpackage #:burgled-feedparser
  (:use #:cl)
  (:import-from #:cpython
                #:+None+)
  (:import-from #:burgled-batteries
                #:defpyfun)
  (:import-from #:alexandria
                #:symbolicate)
  (:export #:parse
           #:parse*
           #:*user-agent*
           #:access))
