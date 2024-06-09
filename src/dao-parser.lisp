(defpackage makima.dao-parser
  (:use :cl
        :postmodern
        :makima.utils
        :makima.sentry
        :makima.html-watcher)
  (:export :dao-parse-watchers))

(in-package :makima.dao-parser)

(defun dao-parse-watchers ()
  (let* ((common (select-dao 'watcher))
         (html (select-dao 'html-watcher))
         (watchers (concatenate 'list common html)))
    (mapcar #'deserialize-parser watchers)
    (mapcar #'deserialize-handlers watchers)
    (loop for watcher in watchers
          unless (entry-exist (name watcher) *watchers*)
            do (save-watcher watcher))))
