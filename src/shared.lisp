(defpackage makima.shared
  (:use :cl :makima.utils)
  (:export :setting
           :parse-settings
           :*vars-file*
           :tg-api))

(in-package :makima.shared)

(defparameter *vars-file* "~/.config/makima/makima")
(defparameter *settings* nil)

(defparameter tg-api "https://api.telegram.org/bot~a/~a")

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
