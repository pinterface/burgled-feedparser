(in-package #:burgled-feedparser)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (cpython:.is-initialized)
    (burgled-batteries:startup-python))
  (burgled-batteries:import "feedparser"))

(define-symbol-macro module-dict*
    (cpython:module.get-dict* (cpython:import.add-module* "feedparser")))

(defpyfun ("feedparser.parse" parse) (thing &key (etag +none+)
                                                 (modified +none+)
                                                 (agent +none+)
                                                 (referrer +none+)))

(defmacro define-feedparser-var (python-name lisp-name)
  (let ((accessor (symbolicate lisp-name '#:-accessor)))
    `(progn
       (defun ,accessor ()
         (cpython:dict.get-item-string module-dict* ,python-name))
       (defun (setf ,accessor) (new-val)
         (cpython:dict.set-item-string module-dict* ,python-name new-val)
         new-val)
       (define-symbol-macro ,lisp-name (,accessor)))))

(define-feedparser-var "USER_AGENT" *user-agent*)

(defmacro define-hash-reader (hash-name lisp-name)
  (let ((parts (split-sequence #\. hash-name)))
    (labels ((%gethash (parts form)
               (if (rest parts)
                 (%gethash (rest parts) `(gethash ,(first parts) ,form (make-hash-table)))
                 `(gethash ,(first parts) ,form))))
      `(defun ,lisp-name (ob)
         ,(%gethash parts 'ob)))))

;; Hrm...
(define-hash-reader "feed" feed)
(define-hash-reader "feed.title" feed.title)
(define-hash-reader "feed.title_detail" feed.title-detail)
(define-hash-reader "feed.link" feed.link)
(define-hash-reader "feed.links" feed.links)
(define-hash-reader "feed.subtitle" feed.subtitle)
(define-hash-reader "feed.icon" feed.icon)

(define-hash-reader "entries" entries)

(define-hash-reader "title" title)
(define-hash-reader "link" link)
(define-hash-reader "links" links)
(define-hash-reader "summary" summary)
(define-hash-reader "content" content)

;; Better!
(defun access (object &rest parts)
  "A generic reader function for accessing arrays, hash tables, and lists,
as well as the Python versions of those things.  This function will attempt
type conversion if the return value would be a CPython pointer.

Returns two values: ITEM, FOUNDP"
  (do ((parts parts (rest parts))
       (part (first parts) (cadr parts))
       (next object (cond
                      ((null next) nil)
                      ((and (hash-table-p next))
                       (gethash part next))
                      ((and (numberp part) (arrayp next) (< part (length next)))
                       (aref next part))
                      ((and (numberp part) (listp next) (< part (length next)))
                       (nth part next))
                      ;; Python objects
                      ((cffi-sys:null-pointer-p next) nil)
                      ((and (stringp part) (cpython::dict.check next))
                       (let ((ptr (cpython:dict.get-item* next part)))
                         (cpython:.inc-ref ptr) ; dict.get-item returns borrowed pointer
                         ptr))
                      ((and (stringp part) (cpython::object.check next))
                       (cpython:object.get-item* next part))
                      ((and (numberp part) (cpython:sequence.check next)
                            (< part (cpython:sequence.length next)))
                       (cpython:sequence.get-item* next part)))))
      ((endp parts)
       (if (endp parts)
         (values (if (cffi:pointerp next) (cffi:convert-from-foreign next 'cpython::object) next) t)
         (values nil nil)))
    ; empty loop!
    ))

#||

(defparameter *feed* (parse "http://pinterface.livejournal.com/data/atom"))

(defparameter *feed** (parse* "http://pinterface.livejournal.com/data/atom"))

(time (parse "http://pinterface.livejournal.com/data/atom"))
(time (let ((x (parse* "http://pinterface.livejournal.com/data/atom")))
        (cpython:.dec-ref x)))

(access *feed* "entries" 5 "title")
(access *feed* "etag")
(parse "http://pinterface.livejournal.com/data/atom" :etag (access *feed* "etag"))

||#
