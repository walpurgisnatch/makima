(defpackage makima/tests/main
  (:use :cl
        :makima
        :makima.html-watcher
        :fiveam)
  (:export :makima))

(in-package :makima/tests/main)

(setf *on-failure* nil)
(setf *run-test-when-defined* t)
(setf *run-test-when-defined* nil)

(setup)
(print 'started)

(def-suite* makima
  :description "Makima tests")


