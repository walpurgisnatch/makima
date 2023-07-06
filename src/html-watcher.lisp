(in-package :cl-user)
(defpackage makima.html-watcher
  (:use :cl :makima.utils :makima.predicates)
  (:import-from :pero
                :write-log)
  (:export :check-for-html-updates
           :create-record
           :reset-table
           :content
           :*content*))

(in-package :makima.html-watcher)

(defparameter *content* (make-hash-table :test 'equalp))

(defclass content-record ()
  ((name :initarg :name :accessor name)
   (page :initarg :page :accessor page)
   (selector :initarg :selector :accessor selector)
   (content :initarg :content :accessor content :initform nil)
   (predicate :initarg :predicate :accessor predicate :initform nil)
   (handler :initarg :handler :accessor handler :initform nil)
   (once :initarg :once :accessor once :initform nil)))

(defun make-content-record (name page selector &key content predicate handler once)
  (make-instance 'content-record :name name :page page :selector selector
                 :content content :predicate predicate :handler handler :once once))

(defun parse-content (page selector)
  (ss:parse-text page selector))

(defun create-record (name page selector &key content (predicate '(content-updated)) handler once)
  (let* ((content (or content (parse-content page selector))))
    (if (entry-exist name *content*)
        (check-record name page selector handler)
        (progn (write-log :created name content)
               (sethash name (make-content-record
                              name page selector
                              :content content
                              :predicate predicate
                              :handler handler
                              :once once)
                        *content*)))))

(defmethod check-record ((record content-record))
  (with-accessors ((name name) (page page) (selector selector) (handler handler)
                   (current content) (predicate predicate) (once once))
      record
    (let ((content (parse-content page selector)))
      (when (apply (predicate-function predicate)
                   (predicate-args current content predicate))
        (handle handler name current content)
        (if once
            (remhash name *content*)
            (setf current content))))))

(defun handle (handlers name last content)
  (loop for handler in handlers do
    (apply (predicate-function handler)
           (handler-args name last content handler))))

(defun check-for-html-updates ()
  (maphash
   #'(lambda (key record)
       (declare (ignorable key))
       (check-record record))
   *content*))

(defmethod print-object ((obj content-record) stream)
  (print-unreadable-object (obj stream :type t)
    (with-accessors ((name name)) obj
      (format stream "~a" name))))

(defun reset-table ()
  (setf *content* (make-hash-table :test 'equalp)))
