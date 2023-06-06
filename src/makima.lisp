(defpackage makima
  (:use :cl
        :makima.utils
        :makima.sentry
        :makima.heart
        :makima.predicates)
  (:export :main))

(in-package :makima)

(defparameter *conf* nil)
(defparameter *root-dir* "~/.makima")
(defparameter *pages-dir* nil)
(defparameter *data-dir* nil)

(defstruct data
  url
  type
  date
  before
  after)

(defun setup ()
  (pero:logger-setup "~/makima")
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

(defun main (&optional (sleep-time 5))
  ;(makima.daemon:daemonize :exit-parent t)
  (setup)
  (print *heartbeat*)
  (pero:write-log :log "Heartbeat started")
  (loop while *heartbeat* do
    (run-all-checks)
    (sleep sleep-time))
  (pero:write-log :log "Heartbeat stoped")
  ;(makima.daemon:exit)
  )
