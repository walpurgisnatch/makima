(in-package :cl-user)
(defpackage makima.sentry
  (:use :cl :makima.utils :makima.predicates)
  (:import-from :pero
                :write-log)
  (:import-from :makima.html-watcher
                :check-for-html-updates)
  (:import-from :makima.system-watcher
                :check-system-files)
  (:export :run-all-checks))

(in-package :makima.sentry)

(defun run-all-checks ()
  (check-for-html-updates)
  (check-system-files))
