(defpackage makima.files-watcher
  (:use :cl :makima.utils :makima.predicates)
  (:import-from :pero
                :write-log)
  (:export :check-for-pages-updates
           :create-record
           :reset-table
           :hash
           :name
           :*pages*
           :*content-folder*))

(in-package :makima.files-watcher)

(defparameter *pages* (make-hash-table :test 'equalp))
(defparameter *content-folder* "~/makima/pages")

(defclass page ()
  ((name
    :initarg :name
    :accessor name)
   (path
    :initarg :path
    :accessor path)
   (hash
    :initarg :hash
    :accessor hash
    :initform nil)
   (last-time-changed
    :initarg :hash
    :accessor last-time-changed
    :initform nil)))

(defun save-page (path name)
  (ss:download-page
   path
   (merge-with-dir name *content-folder*)))

(defmethod parse-page ((page page))
  (with-accessors ((name name) (path path) (hash hash)) page
    (setf hash (hash-page (save-page path name)))))

(defun make-page (name path)
  (let ((page (make-instance 'page :name name :path path)))
    (parse-page page)
    page))

(defun create-record (name path)
  (let ((page (make-page name path)))
    (sethash name page *pages*)))

(defmethod check-record ((page page))
  (with-accessors ((name name) (path path) (current hash)) page    
    (let ((hash (hash-page (ss:safe-get path))))
      (unless (equal hash current)
        (save-page path name)
        (setf current hash)))))

(defun check-for-pages-updates ()
  (maphash
   #'(lambda (key record)
       (declare (ignorable key))
       (check-record record))
   *pages*))

(defmethod print-object ((obj page) stream)
  (print-unreadable-object (obj stream :type t)
    (with-accessors ((name name)
                     (path path))
        obj
      (format stream "~a, path: ~a" name path))))

(defun reset-table ()
  (setf *pages* (make-hash-table :test 'equalp)))
