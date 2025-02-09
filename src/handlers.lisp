(defpackage makima.handlers
  (:use :cl :makima.utils)
  (:import-from :makima.shared
                :setting)
  (:import-from :pero
                :write-log)
  (:export :log-update
           :write-line-to
           :tg-message
           :run-external))

(in-package :makima.handlers)

(defmacro defaction (name args &body body)
  `(defun ,name (watcher ,@args) ,@body))

(defaction log-update (name content)
  (write-log :changes name content))

(defaction write-line-to (file line)
   (with-open-file (stream file :direction :output :if-exists :supersede :if-does-not-exist :create)
    (write-line (or line "nil") stream)))

(defaction tg-message (format &rest args)
  (dex:post (format nil (setting "tg-api") (setting "tg-token") "sendMessage")
            :content `(("chat_id" . ,(setting "tg-user-id"))
                       ("text" . ,(apply #'format nil format args)))))

(defaction run-external (&rest args)
  (uiop:run-program (format nil "~{~a~^ ~}" args) :output :string))
