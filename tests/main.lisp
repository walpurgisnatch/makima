(defpackage makima/tests/main
  (:use :cl
        :makima
        :makima.utils
        :makima.sentry
        :fiveam)
  (:import-from :postmodern
                :with-connection
                :query)
  (:import-from :makima.heart
                :beat)
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

(defparameter *test-var* "100")

(test init
  (clear-watchers)
  (with-connection '("makimatest" "makima" "makima" "localhost")
    (create-table 'record)
    (clear-records)))

(test heartbeat
  (let ((watcher (create-watcher
                  :name "beat-test"
                  :target '*test-var*
                  :parser #'symbol-value
                  :handlers (list
                             (make-handler :recordp t)))))
    (with-connection '("makimatest" "makima" "makima" "localhost")
      (beat)
      (is (string= "100" (last-record-value watcher))))))

