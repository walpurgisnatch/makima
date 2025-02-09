(in-package :makima.sentry)

(defmacro handler-list (&rest list)
  `(list ,@(loop for l in list
                 collect `(make-handler ,@l))))

(defmethod last-record-value ((watcher watcher))
  (let ((last (last-record watcher)))
    (when last (value (last-record watcher)))))

(defmethod last-record-timestamp ((watcher watcher))
  (let ((last (last-record watcher)))
    (when last (timestamp (last-record watcher)))))

(defmethod last-records-values ((watcher watcher) count)
  (mapcar #'value (records watcher :limit count)))

;; parsers

(defun status-code (page)
  (ss:get-status-code page))

