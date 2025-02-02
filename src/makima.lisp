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
  (parse-settings *vars-file*)
  (pero:logger-setup "~/makima-logs")
  (pero:create-template "logs" '(:log "~a"))
  (pero:create-template "errors"
                        '(:download-error "Error while downloading page [~a]~%~a~%")
                        '(:error "ERROR~%~a~%"))
  (pero:create-template "content"
                        '(:changes "~a | was updated  with content [~a]")
                        '(:trigger "~a | triggered by value [~a]")
                        '(:created "~a | was created with content [~a]"))
  (pero:create-template "files" '(:file "~a | event was triggered"))
  (pero:create-template "pages" '(:updated "~a | Was updated"))
  (ensure-tables-exists '(watcher html-watcher handler predicate action record))
  (read-watchers))

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
  (when server (funcall server))
  (loop while *heartbeat*
        when (watchers-updatedp) do
          (print "updated")
          (read-watchers)
        end
        do (with-connection (db-credentials)
             (beat))
           (sleep sleep-time)))

