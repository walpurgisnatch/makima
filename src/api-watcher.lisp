(defpackage makima.api-watcher
  (:use :cl
        :postmodern
        :makima.utils
        :makima.predicates
        :makima.sentry)
  (:export :api-watcher
           :url
           :create-api-watcher
           :dao-create-api-watcher
           :parse-data))

(in-package :makima.api-watcher)


(defclass api-watcher (watcher)
  ((url  :col-type (or string db-null) :initform nil
                              :initarg :url :accessor url))
  (:metaclass dao-class)
  (:table-name api-watchers))

(defmethod print-object ((obj api-watcher) stream)
  (print-unreadable-object (obj stream :type t)
    (with-accessors ((name name) (target target) (value current-value) (records records)) obj
      (format stream "~a: ~a = ~a | ~a records" name target value (length records)))))

(defun create-api-watcher (&key name target parser (interval 60) handlers url)
  (save-watcher
   (make-instance 'api-watcher :name name :url url :target target :parser parser
                               :interval interval :handlers handlers)))

(defun dao-create-api-watcher (&key name target parser (interval 60) handlers url)
  (save-watcher
   (make-dao 'api-watcher :name name :url url :target target :parser parser
                          :interval interval :handlers handlers)))

(defmethod parse-target ((watcher api-watcher))
  (with-accessors ((target target) (url url) (parse parser) (current current-value))
      watcher
    (setf current
          (cond ((and parse url target)
                 (funcall parse url target))
                ((and parse target)
                 (funcall parse target))
                ((and url target)
                 (parse-data url target))))))

(defun parse-data (url target)
  (ss:jfinder (ss:safe-get url) target))
