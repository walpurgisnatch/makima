(defpackage makima/tests/html-watcher
  (:use :cl
        :makima
        :makima.sentry
        :makima.html-watcher
        :makima/tests/server
        :makima/tests/main
        :fiveam)
  (:import-from :postmodern
                :with-connection)
  (:export :html-watcher))

(in-package :makima/tests/html-watcher)

(def-suite* html-watcher
  :in makima
  :description "HTML watcher tests")

(defparameter *test-watcher* nil)

(test init
  (setup)
  (define-routes)
  (reset-content-page)
  (setf *test-watcher*
        (create-html-watcher
         :name "html-test"
         :page "localhost:5000/content"
         :target ".link"
         :parser #'ss:parse-text
         :handlers (list
                    (make-handler :recordp t
                                  :actions '((tg-message "current value - ~a" "watcher-current-value"))))))
  (start)
  (sleep 2))

(test html-watcher-test
  (with-connection '("makimatest" "makima" "makima" "localhost")
    (is (null (records *test-watcher*)))
    (is (null (current-value *test-watcher*)))
    (report *test-watcher*)
    (is (= 1 (length (records *test-watcher*))))
    (is (string= "10" (current-value *test-watcher*)))
    (is (string= "10" (last-record-value *test-watcher*)))))
