(defpackage makima.sentry-controller
  (:use :cl
        :makima.utils
        :makima.shared
        :makima.sentry
        :makima.html-watcher
        :makima.api-watcher
        :makima.router)
  (:import-from :postmodern
                :with-connection)
  (:import-from :makima.router
                :defroute))

(in-package :makima.sentry-controller)


;; routes
(defroute "/watcher-actions" :get ()
  (ss:pack-to-json '(type name args doc) makima.actions:*actions-list*))

(defroute "/watcher-predicates" :get ()
  (ss:pack-to-json '(type name args doc) makima.predicates:*predicates-list*))

(defroute "/watcher-parsers" :get ((|type| "general"))
  (ss:pack-to-json '(type name args doc)
                   (remove-if-not #'(lambda (parser) (string= |type| (car parser)))
                                  makima.parsers:*parsers-list*)))

(defroute "/watchers" :get ()
  (watchers-json))

(defroute "/watchers" :post (|type| |name| |target| |parser| |interval| |handlers| |page| |url|)
  (handler-case 
      (let* ((parser `(:parser ,(makima-function |parser|)))
             (handlers `(:handlers ,(create-handlers |handlers|)))
             (default `(:name ,|name| :target ,|target| :interval ,(parse-integer |interval|)))
             (args (append default parser handlers))
             (result nil))
        (setf result
              (Alexandria:switch (|type| :test #'string=)
                ("general" (apply #'create-watcher args))
                ("html" (apply #'create-html-watcher (append args `(:page ,|page|))))
                ("api" (apply #'create-html-watcher (append args `(:url ,|url|))))))
        "ok")
    (error (e)
      `(400 nil (,(jonathan:to-json `(:status ,(format nil "~a" e))))))))

;; Todo Pack to json works only on lists
(defroute "/watchers/:watcher" :get (watcher)
  (ss:pack-to-json '(name value target interval "recordsCount" parsed)
                   (list (watcher-data (get-watcher watcher)))))

(defroute "/watchers/:watcher" :delete (watcher)
  (delete-watcher watcher)
  "ok")

(defroute "/watchers/:watcher/records" :get (watcher (|limit| 50) |offset|)
  (records-json (get-watcher watcher) |limit| |offset|))

(defroute "/watchers/:watcher/last-value" :get (watcher)
  (last-record-value (get-watcher watcher)))

;; utils

(defun watcher-data (watcher)
  (object-data watcher (name last-record-value target interval)
    (records-count watcher)
    (format-time (last-record-timestamp watcher))))

(defun watchers-json ()
  (let ((result nil))
    (maphash #'(lambda (name watcher) (declare (ignorable name))
                 (push (watcher-data watcher) result))
             *watchers*)
    (ss:pack-to-json '(name value target interval "recordsCount" parsed) result)))

(defun records-json (watcher &optional limit offset)
  (json-data-of (records watcher :limit limit :offset offset) (id watcher value timestamp) (id watcher value timestamp)))

(defun create-handlers (list)
  (loop for handler in list
        collect (make-handler :recordp (arg handler "recordp")
                              :once (arg handler "once")
                              :predicate (prepare-predicate (arg handler "predicate"))
                              :actions (prepare-actions (arg handler "actions")))))

(defun prepare-predicate (predicate)
  (if predicate
      (read-from-string (format nil "(~a)" predicate))))

(defun prepare-actions (actions)
  (if actions
      (read-from-string (format nil "(~{(~a)~})" actions))))

