;(ql:quickload '(clack ningle jonathan))

(defpackage makima/tests/server
  (:use :cl)
  (:import-from :makima/tests/data
                :*pages-data*
                :*content-data*)
  (:export :start
           :stop
           :reset-page
           :reset-content
           :next-page
           :next-content))

(in-package :makima/tests/server)

(defparameter *pages* *pages-data*)
(defparameter *content* *content-data*)

(defvar *app* (make-instance 'ningle:<app>))

(defvar *server* nil)

(defparameter *items* '((:|id| 0 :|name| "item 1" :|description| "Lorem ipsum dolor sit amet, consectetur adipiscing elit." :|cost| 4100)
                  (:|id| 1 :|name| "item 2" :|description| "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper sapien tellus, sit amet facilisis erat varius ac. " :|cost| 2020)
                  (:|id| 2 :|name| "another" :|description| "Lorem ipsum dolor sit amet, consectetur adipiscing elit. " :|cost| 6000)
                  (:|id| 3 :|name| "here we go" :|description| " Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque ullamcorper sapien tellus, sit amet facilisis erat varius ac. Quisque commodo elit neque, vel rhoncus nulla pulvinar et." :|cost| 1500)
                  (:|id| 4 :|name| "sudo" :|description| "ls cd ls" :|cost| 3400)))

(defmacro defjsonroute (path &body body)
  `(setf (ningle:route *app* ,path)
         #'(lambda (params)
             (declare (ignore params))
             (setf (lack.response:response-headers ningle:*response*)
                   (append (lack.response:response-headers ningle:*response*)
                           (list :content-type "application/json")
                           (list :access-control-allow-origin "*")))
             ,@body)))

(defun start ()
  (if *server*
      (format t "Already")
      (setf *server* (clack:clackup *app*))))

(defun stop ()
  (if *server*
      (progn (clack:stop *server*)
             (setf *server* nil))
      (format t "Not running")))

(defun reset-pages ()
  (setf *pages* *pages-data*)
  (define-routes))
(defun reset-content ()
  (setf *content* *content-data*)
  (define-routes))

(defun next-page ()
  (setf *pages* (cdr *pages*))
  (define-routes))
(defun next-content ()
  (setf *content* (cdr *content*))
  (define-routes))

(defun ignore-warning (condition)
   (declare (ignore condition))
   (muffle-warning))

(defun define-routes ()
  (handler-bind ((warning #'ignore-warning))
    (setf (ningle:route *app* "/") "Fine")

    (setf (ningle:route *app* "/page") (car *pages*))

    (setf (ningle:route *app* "/content") (car *content*))

    (defjsonroute "/api/items"
      (jonathan:to-json *items*))))

(define-routes)
