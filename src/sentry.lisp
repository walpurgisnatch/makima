(in-package :cl-user)
(defpackage makima.sentry
  (:use :cl :makima.utils)
  (:import-from :pero
                :write-log)
  (:export :check-for-content-updates))

(in-package :makima.sentry)

(defparameter *table* (make-hash-table))

(defparameter *content* (make-hash-table :test 'equalp))

;(setf *content* nil)

(defstruct (content-record (:constructor make-content-record (page selector name content)))
  page
  selector
  name
  content)

;; Content-Record updates

(defun parse-content (page selector)
  (ss:parse-text page selector))

(defun create-record (name page selector)
  (let* ((content (parse-content page selector)))
    (if (entry-exist name *content*)
        (content-updated name page selector)
        (progn (sethash name (make-content-record page selector name content) *content*)
               (write-log :created name content)))))

(defun content-updated (name page selector)
  (let ((content (parse-content page selector))
        (current (gethash name *content*)))
    (unless (equal content (content-record-content current))
      (setf (content-record-content current) content)
      (sethash name current *content*)
      (write-log :changes name content))))

(defun check-for-content-updates ()
  (maphash #'(lambda (key record)
               (content-updated key
                                (content-record-page record)
                                (content-record-selector record)))
           *content*))

