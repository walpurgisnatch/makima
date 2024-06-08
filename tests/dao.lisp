(defpackage makima/tests/dao
  (:use :cl
        :makima.utils
        :makima.shared
        :makima.sentry
        :makima/tests/main
        :postmodern
        :fiveam)
  (:export :dao-tests))

(in-package :makima/tests/dao)

(def-suite* dao-tests
  :in makima
  :description "Dao tests")

(defparameter *test-watcher* nil)
