(defpackage makima/tests/files-watcher
  (:use :cl
        :makima.files-watcher
        :makima/tests/server
        :makima/tests/main
        :fiveam)
  (:import-from :makima.utils
                :hash-page
                :merge-with-dir)
  (:export :test-files-watcher))

(in-package :makima/tests/files-watcher)

(defparameter *page-file* nil)

(def-suite* files-watcher
  :description "files-watcher tests")

(test init
  (reset-table)
  (reset-content-page)
  (start))

(test create-record-test
  (let ((result (create-record "jahych" "localhost:5000/content")))
    (is (not (null result)))
    (is (equal (hash result) "a039700a33ea857ff70f7e8a6604d9ee"))
    (is (equal result (gethash "jahych" *pages*)))
    (is (setf *page-file* (probe-file (merge-with-dir (name result) *content-folder*))))))

(defun test-files-watcher ()
  (run! 'files-watcher))
