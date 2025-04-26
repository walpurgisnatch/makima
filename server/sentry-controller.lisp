(defpackage makima.sentry-controller
  (:use :cl
        :makima.utils
        :makima.shared
        :makima.sentry
        :makima.router)
  (:import-from :postmodern
                :with-connection)
  (:import-from :makima.router
                :defroute))

(in-package :makima.sentry-controller)

(defmacro object-data (obj slots &body body)
  `(with-accessors ,(loop for slot in slots
                          collect (list slot slot))
       ,obj
     (list ,@slots ,@body)))

(defmacro json-data-of (objl keys vals &body body)
  `(ss:pack-to-json ',keys (mapcar #'(lambda (obj) (object-data obj ,vals ,@body)) ,objl)))

(defun watcher-data (watcher)
  (object-data watcher (name last-record-value)
    (length (records watcher))
    (format-time (last-record-timestamp watcher))))

(defun watchers-json ()
  (let ((result nil))
    (maphash #'(lambda (name watcher) (declare (ignorable name))
                 (push (watcher-data watcher) result))
             *watchers*)
    (ss:pack-to-json '(name value "recordsCount" parsed) result)))

(defun records-json (watcher &optional limit offset)
  (json-data-of (records watcher :limit limit :offset offset) (id watcher value timestamp) (id watcher value timestamp)))

;; routes
(defroute "/watchers" :get ()
  (watchers-json))

(defroute "/watchers" :post (|type| |name| |target| |parser| |interval| |handlers| |page|)
  (format t "~a ~a ~a ~a ~a ~a" |type| |name| |target| |parser| |interval| |handlers|))

(defroute "/:watcher/records" :get (watcher (|limit| 50) |offset|)
  (records-json (get-watcher watcher) |limit| |offset|))

;; TODO Pack to json works only on lists
(defroute "/:watcher" :get (watcher)
  (ss:pack-to-json '(name value "recordsCount" parsed)
                   (list (watcher-data (get-watcher watcher)))))

(defroute "/:watcher/last-value" :get (watcher)
  (last-record-value (get-watcher watcher)))
