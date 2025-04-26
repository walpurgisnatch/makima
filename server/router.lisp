(defpackage makima.router
  (:use :cl :makima.utils)
  (:import-from :postmodern
                :with-connection)
  (:import-from :makima.shared
                :db-credentials)
  (:import-from :makima.server
                :*app*)
  (:export :defroute))

(in-package :makima.router)

(defun params-form (params-symb lambda-list)
  (let ((pair (gensym "PAIR")))
    `(nconc
      ,@(loop for arg in lambda-list
              collect
              (destructuring-bind (arg &optional default specified)
                  (if (consp arg) arg (list arg))
                (declare (ignore default specified))
                `(let ((,pair (assoc ,(symbol-name arg)
                                     ,params-symb
                                     :test #'string=)))
                   (if ,pair
                       (list ,(intern (symbol-name arg) :keyword) (cdr ,pair))
                       nil)))))))

(defmacro defroute (path method args &body body)
  (let ((params (gensym "PARAMS")))
    `(setf (ningle:route *app* ,(concatenate 'string "/api" path) :method ,method)
           (lambda (,params)
             (declare (ignorable ,params))
             (setf (lack.response:response-headers ningle:*response*)
                   (append (lack.response:response-headers ningle:*response*)
                           (list :content-type "application/json")
                           (list :access-control-allow-origin "*")))
             (destructuring-bind (&key ,@args)
                 ,(params-form params args)
               (handler-case
                   (with-connection (db-credentials)
                     ,@body)
                 (error (e)
                   (trace e)
                   (format *standard-output* "~&Error: ~A~%" e))))))))

