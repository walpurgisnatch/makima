(defpackage makima.actions
  (:use :cl :makima.utils)
  (:import-from :makima.shared
                :setting)
  (:import-from :pero
                :write-log)
  (:export :*actions-list*
           :log-update
           :write-line-to
           :tg-message
           :run-external))

(in-package :makima.actions)


(defparameter *actions-list* nil)

(defmacro defaction (name args type doc &body body)
  `(eval-when (:load-toplevel)
     (unless (find ',name *actions-list* :key #'cadr)
         (push (list ',type ',name ,(coerce args 'vector) ,doc) *actions-list*))
     (defun ,name (watcher ,@args) ,@body)))

;; actions

(defaction log-update (name content) general
  "Update log"
  (write-log :changes name content))

(defaction write-line-to (file line) general
  "Write line to file"
  (with-open-file (stream file :direction :output :if-exists :supersede :if-does-not-exist :create)
    (write-line (or line "nil") stream)))

(defaction tg-message (format &rest args) general
  "Send tg message"
  (dex:post (format nil (setting "tg-api") (setting "tg-token") "sendMessage")
            :content `(("chat_id" . ,(setting "tg-user-id"))
                       ("text" . ,(apply #'format nil format args)))))

(defaction run-external (&rest args) general    
  "Run external program"
  (uiop:run-program (format nil "~{~a~^ ~}" args) :output :string))

