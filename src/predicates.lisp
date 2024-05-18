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

(defmacro string-as-float-comparsion (fun &rest args)
  `(,fun ,@(loop for arg in args collect `(parse-float ,arg))))

(defun content-updated (last new)
  (not (equal last new)))

(defun in-content (content regex)
  (cl-ppcre:scan-to-strings regex content))

(defun more-than (content arg)
  (string-as-float-comparsion > content arg))

(defun more-or-equal-than (content arg)
  (string-as-float-comparsion >= content arg))

(defun less-than (content arg)
  (string-as-float-comparsion < content arg))

(defun less-or-equal-than (content arg)
  (string-as-float-comparsion <= content arg))
