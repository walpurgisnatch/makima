(defpackage makima.heart
  (:use :cl :makima.utils)
  (:import-from :makima.sentry
                :*watchers*
                :interval-passed
                :report)
  (:export :*heartbeat*
           :beat
           :heart-stop))

(in-package :makima.heart)

(defparameter *heartbeat* t)

(defun heart-stop ()
  (setf *heartbeat* nil))

(defun beat ()
  (let ((time (get-universal-time)))
    (loop for watcher in *watchers*
          if (interval-passed time watcher)
            do (report watcher))))
