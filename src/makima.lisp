(defpackage makima
  (:use :cl
        :makima.utils
        :makima.shared
        :makima.heart
        :makima.sentry
        :makima.html-watcher
        :makima.predicates
        :makima.handlers)
  (:import-from :postmodern
                :execute
                :query
                :dao-table-definition
                :with-connection)
  (:export :main
           :main-deamonless
           :setup
           :records-tablep
           :create-records-table))

(in-package :makima)


(defun setup ()
  (ensure-files-exists)
  (parse-settings)
  (ensure-tables-exists '(watcher html-watcher handler predicate action record))
  (restore-watchers))

(setup)

(defun main (&optional server (sleep-time 1))
  (heart-start)
  (print 'started)
  (makima.daemon:daemonize :exit-parent t)
  (when server (funcall server))
  (loop while *heartbeat*
        when (watchers-updatedp) do
          (print "updated")
          (read-watchers)
        end
        do (with-connection (db-credentials)
             (beat))
           (sleep sleep-time))
  (makima.daemon:exit))

(defun main-deamonless (&optional server (sleep-time 1))
  (heart-start)
  (print 'started)
  (when server (funcall server :address "0.0.0.0" :port 7143))
  (loop while *heartbeat*
        when (watchers-updatedp) do
          (print "updated")
          (read-watchers)
        end
        do (with-connection (db-credentials)
             (beat))
           (sleep sleep-time)))

