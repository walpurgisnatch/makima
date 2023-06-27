(defpackage makima/tests/html-watcher
  (:use :cl
        :makima.html-watcher
        :makima/tests/server
        :makima/tests/main
        :fiveam))

(in-package :makima/tests/html-watcher)

(def-suite* html-watcher
  :in makima
  :description "HTML watcher tests")

(test init
  (reset-table)
  (reset-content)
  (when (setq stop (probe-file "~/makima/stop"))
    (delete-file stop))
  (start))

(test create-record
  (let ((result (makima.html-watcher:create-record "jahych1" "http://localhost:5000/content" "span.text:nth-child(1)" :handler '((shell "touch" "~/makima/stop")))))
    (is (not (null result)))
    (is (equal (content-record-content result) "33"))))

(test check-record-update
  (next-content)
  (check-for-html-updates)
  (is (probe-file "~/makima/stop")))

(test reset
  (when (setq stop (probe-file "~/makima/stop"))
    (delete-file stop)))

(run! 'html-watcher)
