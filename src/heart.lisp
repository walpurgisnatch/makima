(in-package :cl-user)
(defpackage makima.heart
  (:use :cl :makima.utils)
  (:export :*heartbeat*
           :setting
           :parse-settings
           :tg-api
           :heart-stop))

(in-package :makima.heart)

(defparameter *heartbeat* t)
(defparameter *settings* nil)

(defparameter tg-api "https://api.telegram.org/bot~a/~a")

(defun parse-settings (file)
  (let ((settings (make-hash-table :test #'equalp)))
    (with-open-file (stream file)
      (loop with regexp=nil
            for line = (read-line stream nil)
            while line
            do (setf regexp (nth-value 1 (cl-ppcre:scan-to-strings "(.*)=(.*)" line)))
            do (sethash (elt regexp 0)
                        (elt regexp 1)
                        settings)))
    (setf *settings* settings)))

(defun setting (key)
  (gethash key *settings*))

(defun heart-stop ()
  (setf *heartbeat* nil))
