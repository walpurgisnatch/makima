(defpackage makima.heart
  (:use :cl :makima.utils)
  (:export :*heartbeat*
           :beat
           :heart-stop))

(in-package :makima.heart)

(defparameter *heartbeat* t)

(defun heart-stop ()
  (setf *heartbeat* nil))

(defun beat ()
  )
