(defpackage makima.parsers
  (:use :cl :makima.utils :makima.sentry)
  (:export :*parsers-list*
           :parse-content
           :parse-key-value
           :return-target-number
           :status-code))

(in-package :makima.parsers)

(defparameter *parsers-list* nil)

(defmacro defparser (name args type doc &body body)
  `(eval-when (:load-toplevel)
     (push (list ',type ',name ,(coerce args 'vector) ,doc) *parsers-list*)
     (defun ,name ,args ,@body)))

(defparser parse-content (page target) "html"
    "Parse target content"
  (ss:parse-text page target))

(defparser parse-key-value (url target) "api"
    "Parse value of specified key"
  (ss:jfinder (ss:safe-get url) target))

(defparser return-target-number (target) "general"
    "Заглушка"
  (parse-integer target))

(defparser status-code (page) "general"
    "Page status code"
  (ss:get-status-code page))
