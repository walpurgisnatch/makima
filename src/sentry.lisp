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

(defparameter times 40)

(defun run-all-checks ()
  (decf times)
  (when (<= times 0) (setf *heartbeat* nil))
  (check-for-html-updates)
  (check-system-files))
