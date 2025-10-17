(in-package :makima.sentry)

(defmacro handler-list (&rest list)
  `(list ,@(loop for l in list
                 collect `(make-handler ,@l))))

(defmethod last-record ((watcher watcher))
  (with-accessors ((watcher-name name)) watcher
    (car (query-dao 'record
                    (:limit
                     (:order-by
                      (:select '* :from 'records
                       :where (:= 'watcher watcher-name))
                      (:desc 'id))
                     1)))))

(defmethod last-record-value ((watcher watcher))
  (let ((last (last-record watcher)))
    (when last
      (let ((val (value last)))
        (if (equalp val "false")
            nil
            val)))))

(defmethod last-record-timestamp ((watcher watcher))
  (let ((last (last-record watcher)))
    (when last (timestamp (last-record watcher)))))

(defmethod last-records-values ((watcher watcher) count)
  (mapcar #'value (records watcher :limit count)))

(defmethod records-count ((watcher watcher))
  (with-accessors ((watcher-name name)) watcher
    (query (:select (:count '*) :from 'records
            :where (:= 'watcher watcher-name)) :single)))

