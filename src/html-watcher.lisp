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

(defun dao-make-html-watcher (&key name target parser (interval 60) handlers)
  (save-watcher
   (make-dao 'watcher :name name :target target :parser parser
                      :interval interval :handlers handlers)))

(defmethod parse-target ((watcher html-watcher))
  (with-accessors ((target target) (page page) (parse parser) (current current-value))
      watcher
    (setf current
          (cond ((and parse target page)
                 (funcall parse page target))
                ((and parse target)
                 (funcall parse target))
                ((and paget target)
                 (parse-content page target))))))

(defun parse-content (page target)
  (ss:parse-text page target))

