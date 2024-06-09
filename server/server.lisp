(defpackage makima.server
  (:use :cl)
  (:import-from :makima.sentry
                :get-watcher
                :records)
  (:export :start
           :stop))

(in-package :makima.server)

(defvar *app* (make-instance 'ningle:<app>))

(defvar *server* nil)

(defun api-path (path)
  (concatenate 'string "/api" path))

(defmacro defroute (path &body body)
  `(setf (ningle:route *app*
                       ,(concatenate 'string "/api" path))
         #'(lambda (params)
             (setf (lack.response:response-headers ningle:*response*)
                   (append (lack.response:response-headers ningle:*response*)
                           (list :content-type "application/json")
                           (list :access-control-allow-origin "*")))
             ,@body)))

(defun start ()
  (if *server*
      (format t "Already running")
      (setf *server* (clack:clackup *app* :port 7144))))

(defun stop ()
  (if *server*
      (progn (clack:stop *server*)
             (setf *server* nil))
      (format t "Not running")))

(defroute "/:watcher/records"
  (let ((watcher (cdr (assoc :watcher params))))
  (records (get-watcher watcher))))
