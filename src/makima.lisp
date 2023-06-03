(defpackage makima
  (:use :cl :makima.utils :makima.sentry)
  (:export :main))

(in-package :makima)

(defparameter *heartbeat* t)
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
                        '(:created "~a | was created with content [~a]"))
  (pero:create-template "pages" '(:updated "~a | Was updated")))

(defun main (dir &optional (sleep-time 5))
  ;(makima.daemon:daemonize :exit-parent t)
  (setup dir)
  (pero:write-log :log "Heartbeat started")
  (loop while *heartbeat* do
    (run-all-checks)
    (sleep sleep-time))
  (pero:write-log :log "Heartbeat stoped")
  ;(makima.daemon:exit)
  )

(defparameter times 40)

(defun run-all-checks ()
  (decf times)
  (when (<= times 0) (setf *heartbeat* nil))
  (check-for-content-updates))

