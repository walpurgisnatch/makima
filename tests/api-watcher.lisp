(defpackage makima/tests/api-watcher
  (:use :cl
        :makima
        :makima.sentry
        :makima.api-watcher
        :makima/tests/server
        :makima/tests/main
        :fiveam)
  (:import-from :postmodern
                :with-connection)
  (:export :api-watcher))

(in-package :makima/tests/api-watcher)

(def-suite* api-watcher
  :in makima
  :description "API watcher tests")

(defparameter *test-watcher* nil)

(test init
  (setup)
  (define-routes)
  (setf *test-watcher*
        (create-api-watcher
         :name "api-test"
         :url "http://localhost:5000/api/bigone"
         :target "target"
         :handlers (list
                    (make-handler :recordp t))))
  (start)
  (sleep 2))

(test api-watcher-test
  (with-connection '("makimatest" "makima" "makima" "localhost")
    (is (null (records *test-watcher*)))
    (is (null (current-value *test-watcher*)))
    (report *test-watcher*)
    (is (= 1 (length (records *test-watcher*))))
    (is (string= "that will do" (current-value *test-watcher*)))
    (is (string= "that will do" (last-record-value *test-watcher*)))))
