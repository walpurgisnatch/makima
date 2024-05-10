(in-package :cl-user)
(defpackage makima.predicates
  (:use :cl :makima.utils)
  (:import-from :pero
                :write-log)
  (:export :content-updated
           :in-content
           :more-than
           :more-or-equal-than
           :less-then
           :less-or-equal-than))

(in-package :makima.predicates)

(defmacro defpred (name args &body body)
  `(defun ,name ,(cons 'last 'current args) ,@body))

(defmacro string-as-float-comparsion (fun &rest args)
  `(,fun ,@(loop for arg in args collect `(parse-float ,arg))))

(defpred content-updated ()
  (not (equal last current)))

(defpred in-current (regex)
  (cl-ppcre:scan-to-strings regex current))

(defpred more-than (arg)
  (string-as-float-comparsion > current arg))

(defpred more-or-equal-than (arg)
  (string-as-float-comparsion >= current arg))

(defpred less-than (arg)
  (string-as-float-comparsion < current arg))

(defpred less-or-equal-than (arg)
  (string-as-float-comparsion <= current arg))
