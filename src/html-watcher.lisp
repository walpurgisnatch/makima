(in-package :cl-user)
(defpackage makima.html-watcher
  (:use :cl :makima.utils :makima.predicates)
  (:import-from :pero
                :write-log)
  (:export :check-for-html-updates))

(in-package :makima.html-watcher)

(defparameter *content* (make-hash-table :test 'equalp))

;(setf *content* nil)

; predicates is a list of strings first elements of which name of predicate
; and rest is arguments
(defstruct (content-record (:constructor make-content-record (name page selector &key content predicate handler once)))
  name
  page
  selector
  content
  predicate
  handler
  once)

(defun parse-content (page selector)
  (ss:parse-text page selector))

(defun create-record (name page selector &key content (predicate '(content-updated)) handler once)
  (let* ((content (or content (parse-content page selector))))
    (if (entry-exist name *content*)
        (content-updated name page selector)
        (progn ;(write-log :created name content)
               (sethash name (make-content-record
                              name page selector 
                              :content content
                              :predicate predicate
                              :handler handler
                              :once once)
                        *content*)))))

(defun check-record (name page selector handler)
  (let* ((content (parse-content page selector))
         (current (gethash name *content*))
         (last-value (content-record-content current))
         (predicate (content-record-predicate current)))
    (when (apply (predicate-function predicate)
                 (predicate-args last-value content predicate))
      (if (content-record-once current)
          (remhash name *content*)
          (update-record name current content))
      (apply (predicate-function handler)
             (handler-args name last-value content handler)))))

(defun update-record (name current content)
  (setf (content-record-content current) content)
  (sethash name current *content*))

(defun check-for-html-updates ()
  (maphash
   #'(lambda (key record)
       (check-record        
        key
        (content-record-page record)
        (content-record-selector record)
        (content-record-handler record)))
   *content*))
