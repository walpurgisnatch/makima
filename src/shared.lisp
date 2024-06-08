(defpackage makima.shared
  (:use :cl :makima.utils)
  (:export :setting
           :parse-settings
           :*vars-file*
           :*sentry-file*
           :read-watchers
           :tg-api))

(in-package :makima.shared)

(defparameter *root-folder* "~/.makima")
(defparameter *vars-file* (merge-with-dir "makima.conf" *root-folder*))
(defparameter *sentry-file* (merge-with-dir "sentry.lisp" *root-folder*))
(defparameter *data-folder* (merge-with-dir "data/" *root-folder*))

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

(defun read-watchers ()
  (with-open-file (stream *sentry-file* :if-does-not-exist nil)
    (loop for expression = (read stream nil)
          while expression
          do (eval expression))))

(defun setting (key)
  (gethash key *settings*))
