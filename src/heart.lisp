(in-package :cl-user)
(defpackage makima.heart
  (:use :cl)
  (:export :*heartbeat*
           :heart-stop))

(in-package :makima.heart)

(defparameter *heartbeat* t)

(defun heart-stop ()
  (setf *heartbeat* nil))
