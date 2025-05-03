(defpackage makima.server
  (:use :cl :makima.heart :ningle)
  (:import-from :postmodern
                :with-connection)
  (:import-from :makima.sentry
                :get-watcher
                :records)
  (:import-from :makima.shared
                :db-credentials)
  (:export :start
           :stop
           :run-dev
           :params
           :*app*))

(in-package :makima.server)

(defvar *app* (make-instance 'ningle:<app>))

(defvar *server* nil)

(defun run-dev (&key (address "127.0.0.1") (port 7144))
  (start :address address :port port)
  (makima:main-deamonless))

(defun start (&key (address "127.0.0.1") (port 7144))
  (if *server*
      (format t "Already running")
      (setf *server* (clack:clackup *app* :address address :port port))))


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

(setf (ningle:route *app* "/api/*" :method :OPTIONS)
      #'(lambda (params)
          (setf (lack.response:response-headers ningle:*response*)
                (append (lack.response:response-headers ningle:*response*)
                        (list :Access-Control-Allow-Origin "*")
                        (list :Access-Control-Allow-Headers "*")
                        (list :Access-Control-Allow-Methods "*")))
          (next-route)))
