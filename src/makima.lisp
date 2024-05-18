(defpackage makima
  (:use :cl
        :makima.utils
        :makima.shared
        :makima.heart
        :makima.sentry
        :makima.predicates
        :makima.handlers)
  (:export :main
           :setup))

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
  (pero:create-template "pages" '(:updated "~a | Was updated")))

(defun main (&optional (sleep-time 1))
  ;(makima.daemon:daemonize :exit-parent t)
  (setup)
  (pero:write-log :log "Heartbeat started")
  (loop while *heartbeat* do
    (beat))
  (pero:write-log :log "Heartbeat stoped")
  ;(makima.daemon:exit)
  )
