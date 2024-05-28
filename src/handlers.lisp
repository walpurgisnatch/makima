(defpackage makima.handlers
  (:use :cl :makima.utils)
  (:import-from :makima.shared
                :setting)
  (:import-from :pero
                :write-log)
  (:export :log-update
           :write-line-to
           :tg-message
           :shell))

(in-package :makima.handlers)

(defun log-update (name content)
    (write-log :changes name content))

(defun write-line-to (file line)
   (with-open-file (stream file :direction :output :if-exists :supersede :if-does-not-exist :create)
    (write-line (or line "nil") stream)))

(defun tg-message (format &rest args)
  (dex:post (format nil (setting "tg-api") (setting "tg-token") "sendMessage")
            :content `(("chat_id" . ,(setting "tg-user-id"))
                       ("text" . ,(apply #'format nil format args)))))

(defun shell (&rest args)
  (uiop:run-program (format nil "~{~a~^ ~}" args) :output :string))
