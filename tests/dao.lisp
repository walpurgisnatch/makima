(defpackage makima/tests/db
  (:use :cl
        :makima.utils
        :makima.shared
        :makima.sentry
        :makima/tests/main
        :postmodern
        :fiveam)
  (:export :db-tests))

(in-package :makima/tests/db)

(def-suite* dao-tests
  :in makima
  :description "Dao tests")

(defparameter *test-watcher* nil)
