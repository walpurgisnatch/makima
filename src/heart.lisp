(defpackage makima.heart
  (:use :cl :makima.utils)
  (:import-from :makima.sentry
                :*watchers*
                :interval-passed
                :report)
  (:export :*heartbeat*
           :beat
           :heart-stop
           :heart-start))

(in-package :makima.heart)

(defparameter *heartbeat* t)

(defun heart-stop ()
  (setf *heartbeat* nil))

(defun heart-start ()
  (setf *heartbeat* t))

(defun beat ()
  (let ((time (get-universal-time)))
    (maphash #'(lambda (name watcher) (declare (ignorable name))
                 (when (interval-passed time watcher)
                   (handler-case 
                       (report watcher)
                     (error (e)
                       (format *standard-output* "~&Error: ~A~%" e)))))
             *watchers*)))
