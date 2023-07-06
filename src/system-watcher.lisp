(in-package :cl-user)
(defpackage makima.system-watcher
  (:use :cl :makima.utils :makima.predicates :makima.heart)
  (:import-from :pero
                :write-log)
  (:export :check-system-files
           :heart-stop))

(in-package :makima.system-watcher)

(defparameter *table* (make-hash-table :test 'equalp))

(defclass record ()
  ((name :initarg :name :accessor name)
   (file :initarg :file :accessor file)
   (predicate :initarg :predicate :accessor predicate)
   (handler :initarg :handler :accessor handler)))

(defun make-record (name file predicate handler)
  (make-instance 'record :name name :file file
                         :predicate predicate :handler handler))

(defun create-record (name file predicate handler)
  (sethash name (make-record name file predicate handler) *table*))

(create-record "heart stopper" "~/makima/stop" '(probe-file) '(heart-stop))

(defmethod file-check ((record record))
  (with-accessors ((name name) (file file) (predicate predicate) (handler handler))
      record
  (when (apply (predicate-function predicate) (predicate-args nil file predicate))
    (write-log :file name)
    (apply (predicate-function handler) (cdr handler))))

(defun check-system-files ()
  (maphash
   #'(lambda (key record)
       (declare (ignorable key))
       (file-check record))
   *table*))
