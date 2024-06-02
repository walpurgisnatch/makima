(defpackage makima.shared
  (:use :cl :makima.utils)
  (:export :setting
           :parse-settings
           :*vars-file*
           :tg-api))

(in-package :makima.shared)

(defparameter *root-folder* "~/.makima")
(defparameter *vars-file* (merge-with-dir "makima.conf" *root-folder*))
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

(defun setting (key)
  (gethash key *settings*))
