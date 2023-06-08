(in-package :cl-user)
(defpackage makima.handlers
  (:use :cl :makima.utils)
  (:import-from :makima.heart
                :setting
                :tg-api)
  (:import-from :pero
                :write-log)
  (:export :predicate-update
           :log-update
           :tg-message))

(in-package :makima.handlers)

(defun log-update (meta)
  (destructuring-bind (name current content) meta
    (write-log :changes name content)))

(defun tg-message (meta &optional (text "~a was updated with value ~a"))
  (destructuring-bind (name current content) meta
    (dex:post (format nil tg-api (setting "tg-token") "sendMessage")
              :content `(("chat_id" . ,(setting "tg-user-id"))
                         ("text" . ,(format nil text name content))))))
