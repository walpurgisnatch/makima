(defpackage makima/tests/html-watcher
  (:use :cl
        :makima.sentry
        :makima.html-watcher
        :makima/tests/server
        :makima/tests/main
        :fiveam)
  (:export :html-watcher))

(in-package :makima/tests/html-watcher)

(def-suite* html-watcher
  :in makima
  :description "HTML watcher tests")

(defparameter *init-watcher*
  (create-html-watcher
         :name "test"
         :page "localhost:5000/content"
         :target ".link"
         :parser #'ss:parse-text
         :handlers (list
                    (make-handler :recordp t :once t))))

(defparameter *test-watcher* *init-watcher*)

(test init
  (define-routes)
  (reset-content-page)
  (setf *test-watcher* *init-watcher*)
  (start)
  (sleep 2))

(test html-watcher-test
  (is (null (records *test-watcher*)))
  (is (null (current-value *test-watcher*)))
  (report *test-watcher*)
  (is (= 1 (length (records *test-watcher*))))
  (is (string= "10" (current-value *test-watcher*)))
  (is (string= "10" (last-record-value *test-watcher*))))
