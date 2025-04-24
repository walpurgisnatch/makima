(defpackage makima.shared
  (:use :cl :makima.utils)
  (:import-from :org.shirakumo.file-attributes
                :modification-time)
  (:export :setting
           :parse-settings
           :*sentry-file*
           :*sentry-store*
           :read-watchers
           :watchers-updatedp
           :format-time
           :db-credentials
           :ensure-tables-exists
           :ensure-files-exists))

(in-package :makima.shared)

(defparameter *root-folder* "~/.makima")
(defparameter *config-file* (merge-with-dir "makima.conf" *root-folder*))
(defparameter *sentry-file* (merge-with-dir "sentry.lisp" *root-folder*))
(defparameter *sentry-store* (merge-with-dir "sentry.db" *root-folder*))
(defparameter *data-folder* (merge-with-dir "data/" *root-folder*))

(defparameter *settings* (make-hash-table :test #'equalp))

(defparameter *watchers-updated-at*
  (and (probe-file *sentry-file*)
       (modification-time *sentry-file*)))

(defun ensure-file (file)
  (close (open file :direction :probe :if-does-not-exist :create)))

(defun ensure-files-exists ()
  (unless (probe-file *root-folder*)
    (mkdir *root-folder*))
  (ensure-file *config-file*)
  (ensure-file *sentry-file*)
  (ensure-file *sentry-store*)
  (unless (probe-file *data-folder*)
    (mkdir *data-folder*)))

(defun parse-settings (&optional (file *config-file*))
  (when (probe-file file)
    (let ((settings (make-hash-table :test #'equalp)))
      (with-open-file (stream file)
        (loop with regexp = nil
              for line = (read-line stream nil)
              while line
              do (setf regexp (nth-value 1 (cl-ppcre:scan-to-strings "(.*)=(.*)" line)))
              do (sethash (elt regexp 0)
                          (elt regexp 1)
                          settings)))
      (setf *settings* settings))))

(defun watchers-updatedp ()
  (let ((current (modification-time *sentry-file*)))
    (when (< *watchers-updated-at* current)
      (setf *watchers-updated-at* current)
      t)))

(defun read-watchers ()
  (let ((*package* (find-package :makima)))
    (with-open-file (stream *sentry-file* :if-does-not-exist nil)
      (loop for expression = (read stream nil)
            while expression
            do (eval expression)))))

(defun setting (key)
  (gethash key *settings*))

(defun format-time (timestamp)
  (when (null timestamp) (return-from format-time nil))
  (when (stringp timestamp) (setf timestamp (parse-integer timestamp)))
  (local-time:format-timestring
   nil
   (local-time:universal-to-timestamp timestamp)
   :format '((:day 2) "." (:month 2) "." :year " " (:hour 2) ":" (:min 2))))

(defun db-credentials ()
  (let ((port (setting "db-port")))
    (list (or (setting "db-name") "makima")
          (or (setting "db-user") "makima")
          (or (setting "db-pass") "makima")
          (or (setting "db-host") "db")
          :port (or (and port (parse-integer port)) 5433))))

(defun ensure-tables-exists (tables)
  (postmodern:with-connection (db-credentials)
    (loop for table in tables
          do (create-table table))))
