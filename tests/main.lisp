(defpackage makima/tests/main
  (:use :cl
        :makima
        :fiveam)
  (:export :makima))

(in-package :makima/tests/main)

(setf *on-failure* nil)
(setf *on-error* :debug)
(setf *run-test-when-defined* nil)

;(setup)
(print 'started)

(def-suite* makima
  :description "Makima tests")


