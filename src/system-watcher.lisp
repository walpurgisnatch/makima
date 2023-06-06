(in-package :cl-user)
(defpackage makima.system-watcher
  (:use :cl :makima.utils :makima.predicates :makima.heart)
  (:import-from :pero
                :write-log)
  (:export :check-system-files
           :heart-stop))

(in-package :makima.system-watcher)

(defparameter *table* (make-hash-table :test 'equalp))

(defstruct (record (:constructor make-record (name file predicate handler)))
  name
  file
  predicate
  handler)

(defun create-record (name file predicate handler)
  (sethash name (make-record name file predicate handler) *table*))

(create-record "heart stopper" "~/makima/stop" '(probe-file) '(heart-stop))

(defun file-check (name file predicate handler)
  (when (apply (predicate-function predicate) (predicate-args file predicate))
    (write-log :file name)
    (apply (predicate-function handler) (cdr handler))))

(defun check-system-files ()
  (maphash
   #'(lambda (key record)
       (file-check
        key
        (record-file record)
        (record-predicate record)
        (record-handler record)))
   *table*))
