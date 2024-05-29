(defpackage makima/tests/main
  (:use :cl
        :makima
        :fiveam)
  (:import-from :postmodern
                :with-connection
                :query)
  (:export :makima
           :clear-records))

(in-package :makima/tests/main)

(setf *on-failure* nil)
(setf *on-error* :debug)
(setf *run-test-when-defined* nil)

(def-suite* makima
  :description "Makima tests")

(defun clear-records ()
  (query "delete from records"))

(test init
  (with-connection '("makimatest" "makima" "makima" "localhost")
    (create-records-table)
    (clear-records)))


