(defpackage makima/tests/dao
  (:use :cl
        :makima.utils
        :makima.shared
        :makima.sentry
        :makima.html-watcher
        :makima.dao-parser
        :makima/tests/server
        :makima/tests/main
        :postmodern
        :fiveam)
  (:import-from :makima
                :setup)
  (:export :dao-tests))

(in-package :makima/tests/dao)

(def-suite* dao-tests
  :in makima
  :description "Dao tests")

(defparameter *test-watcher* nil)

(defun clear-tables ()
  (query "delete from records")
  (query "delete from handlers")
  (query "delete from actions")
  (query "delete from predicates")
  (query "delete from html_watchers")
  (query "delete from watchers"))

(test init
  (setf *test-watcher* nil)
  (define-routes)
  (reset-content-page)
  (start)
  (with-connection '("makimatest" "makima" "makima" "localhost")
    (loop for table in '(html-watcher watcher handler predicate action record)
          do (create-table table))
    (clear-tables)
    (dao-create-html-watcher
     :name "dao-test"
     :page "http://localhost:5000/content"
     :target ".link"
     :parser "parse-content"
     :handlers (vector
                (dao-make-handler :recordp t
                                  :predicate '(stringp "watcher-current-value")))))
                                  ;:actions '((tg-message "current value - ~a" "watcher-current-value"))
  (clear-watchers))

(test html-watcher-test
  (with-connection '("makimatest" "makima" "makima" "localhost")
    (dao-parse-watchers)
    (is (gethash "dao-test" *watchers*))
    (setf *test-watcher* (gethash "dao-test" *watchers*))
    (is (null (records *test-watcher*)))
    (is (string= "false" (current-value *test-watcher*)))
    (report *test-watcher*)
    (is (= 1 (length (records *test-watcher*))))
    (is (string= "10" (current-value *test-watcher*)))
    (is (string= "10" (last-record-value *test-watcher*)))))
