(defpackage makima.server
  (:use :cl :makima.heart)
  (:import-from :postmodern
                :with-connection)
  (:import-from :makima.sentry
                :get-watcher
                :records)
  (:export :start
           :stop
           :params))

(in-package :makima.server)

(defvar *app* (make-instance 'ningle:<app>))

(defvar *server* nil)

(defmacro defroute (path &body body)
  `(setf (ningle:route *app*
                       ,(concatenate 'string "/api" path))
         #'(lambda (params)
             (setf (lack.response:response-headers ningle:*response*)
                   (append (lack.response:response-headers ningle:*response*)
                           (list :content-type "application/json")
                           (list :access-control-allow-origin "*")))
             (with-connection '("makima" "makima" "makima" "localhost")
               ,@body))))

(defun start ()
  (if *server*
      (format t "Already running")
      (setf *server* (clack:clackup *app* :port 7144))))

(defun stop ()
  (if *server*
      (progn (clack:stop *server*)
             (setf *server* nil))
      (format t "Not running")))

(defun heartbeat ()
  (if *heartbeat*
      "true"
      "false"))

(setf (ningle:route *app* "/heart-beat")
      #'(lambda (params)
          (heartbeat)))

(setf (ningle:route *app* "/heart-stop")
      #'(lambda (params)
          (heart-stop)
          (heartbeat)))
