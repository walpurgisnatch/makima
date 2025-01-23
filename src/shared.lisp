(defpackage makima.shared
  (:use :cl :makima.utils)
  (:export :setting
           :parse-settings
           :*vars-file*
           :*sentry-file*
           :read-watchers
           :watchers-updatedp
           :format-time
           :db-credentials
           :ensure-tables-exists))

(in-package :makima.shared)

(defparameter *root-folder* "~/.makima")
(defparameter *vars-file* (merge-with-dir "makima.conf" *root-folder*))
(defparameter *sentry-file* (merge-with-dir "sentry.lisp" *root-folder*))
(defparameter *data-folder* (merge-with-dir "data/" *root-folder*))

(defparameter *watchers-updated-at*
  (org.shirakumo.file-attributes:modification-time #p"~/.makima/sentry.lisp"))

(defparameter *settings* nil)

(defun parse-settings (file)
  (let ((settings (make-hash-table :test #'equalp)))
    (with-open-file (stream file)
      (loop with regexp = nil
            for line = (read-line stream nil)
            while line
            do (setf regexp (nth-value 1 (cl-ppcre:scan-to-strings "(.*)=(.*)" line)))
            do (sethash (elt regexp 0)
                        (elt regexp 1)
                        settings)))
    (setf *settings* settings)))

(defun watchers-updatedp ()
  (let ((current (org.shirakumo.file-attributes:modification-time #p"~/.makima/sentry.lisp")))
    (when (< *watchers-updated-at* current)
      (setf *watchers-updated-at* current)
      t)))

(defun read-watchers ()
  (with-open-file (stream *sentry-file* :if-does-not-exist nil)
    (loop for expression = (read stream nil)
          while expression
          do (print expression)
          do (eval expression))))

(defun setting (key)
  (gethash key *settings*))

(defun format-time  (timestamp)
  (when (stringp timestamp) (setf timestamp (parse-integer timestamp)))
  (local-time:format-timestring
   nil
   (local-time:universal-to-timestamp timestamp)
   :format '(:day "." :month "." :year " " :hour ":" :min)))

(defun db-credentials ()
  (list (setting "db-name")
        (setting "db-user")
        (setting "db-pass")
        (setting "db-host")))

(defun ensure-tables-exists (tables)
  (postmodern:with-connection (db-credentials)
    (loop for table in tables
          do (create-table table))))
