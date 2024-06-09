(defpackage makima.html-watcher
  (:use :cl
        :postmodern
        :makima.utils
        :makima.predicates
        :makima.sentry)
  (:export :html-watcher
           :page
           :create-html-watcher
           :dao-create-html-watcher
           :parse-content))

(in-package :makima.html-watcher)

(defclass html-watcher (watcher)
  ((page  :col-type (or string db-null) :initform nil
                               :initarg :page :accessor page))
  (:metaclass dao-class)
  (:table-name html-watchers))

(defmethod print-object ((obj html-watcher) stream)
  (print-unreadable-object (obj stream :type t)
    (with-accessors ((name name) (value current-value) (records records)) obj
      (format stream "~a: ~a | ~a" name value (length records)))))

(defun create-html-watcher (&key name target parser interval handlers page)
  (save-watcher
   (make-instance 'html-watcher :name name :page page :target target :parser parser
                                :interval interval :handlers handlers)))

(defun dao-create-html-watcher (&key name target parser (interval 60) handlers page)
  (save-watcher
   (make-dao 'html-watcher :name name :page page :target target :parser parser
                           :interval interval :handlers handlers)))

(defmethod parse-target ((watcher html-watcher))
  (with-accessors ((target target) (page page) (parse parser) (current current-value))
      watcher
    (setf current
          (cond ((and parse page target)
                 (funcall parse page target))
                ((and parse target)
                 (funcall parse target))
                ((and page target)
                 (parse-content page target))))))

(defun parse-content (page target)
  (ss:parse-text page target))

