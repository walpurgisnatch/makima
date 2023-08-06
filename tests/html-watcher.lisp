(defpackage makima/tests/html-watcher
  (:use :cl
        :makima.html-watcher
        :makima/tests/server
        :makima/tests/main
        :fiveam)
  (:export :test-html-watcher))

(in-package :makima/tests/html-watcher)

(defparameter stopf nil)

(def-suite* html-watcher
  :in makima
  :description "HTML watcher tests")

(test init
  (reset-table)
  (reset-content-page)
  (when (setq stopf (probe-file "~/makima/stop"))
    (delete-file stopf))
  (start))

(test create-record-test
  (let ((result (create-record "jahych-common" "http://localhost:5000/content" "span.text:nth-child(1)" :handler '((tg-message "~{~a was updated with content ~a~}" "makima-name" "makima-content")))))
    (create-record "jahych-predicate" "http://localhost:5000/content" "span.text:nth-child(1)" :predicate '(more-or-equal-than 44) :handler '((tg-message "~{~a was updated with content ~a~}" "makima-name" "makima-content")))
    (is (not (null result)))
    (is (equal (content result) "33"))))

(test record-update-test
  (next-content-page)
  (check-for-html-updates)
  (is (equal (content (gethash "jahych-common" *content*)) "39"))
  (is (equal (content (gethash "jahych-predicate" *content*)) "33")))

(check-for-html-updates)

(test record-predicate-test
  (next-content-page)
  (check-for-html-updates)
  (next-content-page)
  (check-for-html-updates)
  (is (equal (content (gethash "jahych-predicate" *content*)) "44")))

(test reset
  (when (setq stopf (probe-file "~/makima/stop"))
    (delete-file stopf)))

(defun test-html-watcher ()
  (run! 'html-watcher))

(test-html-watcher)
