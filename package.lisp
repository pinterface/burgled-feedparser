(defpackage #:burgled-feedparser
  (:use #:cl)
  (:import-from #:cpython
                #:+None+)
  (:import-from #:burgled-batteries
                #:defpyfun)
  (:import-from #:alexandria
                #:symbolicate)
  (:import-from #:split-sequence
                #:split-sequence)
  (:export #:parse
           #:parse*
           #:*user-agent*
           #:access))
