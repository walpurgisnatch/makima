(in-package :cl-user)
(defpackage makima.sentry
  (:use :cl :makima.utils :makima.predicates)
  (:import-from :pero
                :write-log)
  (:export :check-for-content-updates))

(in-package :makima.sentry)

(defparameter *table* (make-hash-table))

(defparameter *content* (make-hash-table :test 'equalp))

;(setf *content* nil)

; predicates is a list of strings first elements of which name of predicate
; and rest is arguments
(defstruct (content-record (:constructor make-content-record (page selector name &key content predicate)))
  page
  selector
  name
  content
  predicate)

;; Content-Record updates

(defun parse-content (page selector)
  (ss:parse-text page selector))

(defun create-record (name page selector &key content predicate)
  (let* ((content (or content (parse-content page selector))))
    (if (entry-exist name *content*)
        (content-updated name page selector)
        (progn (sethash name (make-content-record
                              page selector name
                              :content content
                              :predicate predicate)
                        *content*)
               ;(write-log :created name content)
               ))))

(defun content-updated (name page selector)
  (let* ((content (parse-content page selector))
         (current (gethash name *content*))
         (predicate (content-record-predicate current)))
    (unless (equal content (content-record-content current))
      (if predicate
          (when (apply (predicate-function predicate)
                       (predicate-args content predicate))
            (predicate-update name current content))
          (simple-update name current content)))))

(defun predicate-function (predicate)
  (symbol-function (intern (string-upcase (car predicate)))))

(defun predicate-args (content predicate)
  (cons content (cdr predicate)))

(defun predicate-update (name current content)
  (setf (content-record-content current) content)
  (sethash name current *content*)
  (write-log :trigger name content))

(defun simple-update (name current content)
  (setf (content-record-content current) content)
  (sethash name current *content*)
  (write-log :changes name content))

(defun check-for-content-updates ()
  (maphash #'(lambda (key record)
               (content-updated key
                                (content-record-page record)
                                (content-record-selector record)))
           *content*))

