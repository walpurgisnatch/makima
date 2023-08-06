(defpackage makima
  (:use :cl
        :makima.utils
        :makima.sentry
        :makima.heart
        :makima.predicates
        :makima.handlers
        :makima.html-watcher
        :makima.system-watcher)
  (:export :main
           :setup))

(in-package :makima)

(defparameter *root-dir* "~/.makima")
(defparameter *project-root* nil)

(defun set-root (&optional dir)
  (handler-case 
      (let ((curr (or dir (uiop/os:getcwd))))
        (if (some #'(lambda (x) (search ".git" (namestring x))) (ls curr))
            (setf *project-root* curr)
            (set-root (upper-directory curr))))
    (error () (format t "Cannot find root directory"))))

(defun setup ()
  (set-root "~/cl/makima")
  (parse-settings (merge-with-dir ".env" *project-root*))
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
  (pero:write-log :log "Heartbeat started")
  (loop while *heartbeat* do
    (run-all-checks)
    (sleep sleep-time))
  (pero:write-log :log "Heartbeat stoped")
  ;(makima.daemon:exit)
  )
