(in-package :cl-user)
(defpackage makima.html-watcher
  (:use :cl
        :postmodern
        :makima.utils
        :makima.predicates
        :makima.sentry)
  (:export :create-html-watcher))

(in-package :makima.html-watcher)

(defclass html-watcher (watcher)
  ((page :initarg :page :accessor page))
  (:metaclass dao-class))

(defmethod print-object ((obj html-watcher) stream)
  (print-unreadable-object (obj stream :type t)
    (with-accessors ((name name) (value current-value) (records records)) obj
      (format stream "~a: ~a | ~a" name value (length records)))))

(defun create-html-watcher (&key name target parser interval handlers page)
  (save-watcher
   (make-instance 'html-watcher :name name :target target :parser parser
                                :interval interval :handlers handlers :page page)))

(defmethod parse-target ((watcher html-watcher))
  (with-accessors ((target target) (page page) (parse parser) (current current-value))
      watcher
    (setf current (ss:parse-text page target))))

