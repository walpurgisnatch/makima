;(ql:quickload '(clack ningle jonathan))

(defpackage makima/tests/server
  (:use :cl)
  (:import-from :makima/tests/data
                :*content-data*)
  (:export :start
           :stop
           :define-routes
           :reset-content-page
           :next-content-page))

(in-package :makima/tests/server)

(defparameter *content* *content-data*)

(defvar *app* (make-instance 'ningle:<app>))

(defvar *server* nil)

(defparameter *items* '((:|id| 0 :|name| "item 1" :|description| "Lorem ipsum dolor sit amet" :|cost| 4100)
                  (:|id| 1 :|name| "item 2" :|description| "consectetur adipiscing elit." :|cost| 2020)
                  (:|id| 2 :|name| "another" :|description| "Lorem ipsum" :|cost| 6000)
                  (:|id| 3 :|name| "here we go" :|description| "vel rhoncus nulla pulvinar et." :|cost| 1500)
                  (:|id| 4 :|name| "sudo" :|description| "ls cd ls" :|cost| 3400)))

(defparameter *big-json*
  '((:|id| 0 :|name| "item 1" :|description| "Lorem ipsum dolor sit amet" :|cost| 4100)
    (:|id| 1 :|name| "item 2" :|description| "consectetur adipiscing elit."
             :|data| (:|kek| "wpek" :|here| ((:|wrong| "one" :|end| "here") (:|some| "stuff" :|more| (:|not| "this" :|target| "that will do" :|another| "not") :|lost| "end")) :|lost| "end"))))

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

(defun reset-content-page ()
  (setf *content* *content-data*)
  (define-routes))

(defun next-content-page ()
  (setf *content* (cdr *content*))
  (define-routes))

(defun ignore-warning (condition)
   (declare (ignore condition))
   (muffle-warning))

(defun define-routes ()
  (handler-bind ((warning #'ignore-warning))
    (setf (ningle:route *app* "/") "Fine")

    (setf (ningle:route *app* "/content") (car *content*))

    (defjsonroute "/api/items"
      (jonathan:to-json *items*))
    
    (defjsonroute "/api/bigone"
      (jonathan:to-json *big-json*))))

(define-routes)
