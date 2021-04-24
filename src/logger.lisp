(defpackage :logger
  (:use :cl)
  (:import-from :logger.utils
   :mkdir
   :merge-dirs))

(in-package :logger)

(defvar *log-files* nil)

(defun log-path (log)
    (cdr (assoc log *log-files*)))

(defun create-log-file (log path)
    (push (cons log path) *log-files*))

(defun logger-setup (dir &rest files)
    (progn (mkdir dir)           
           (loop for file in files do
             (let ((log-path (mkdir (cdr file) dir)))
                 (create-log-file (car file) log-path)))))

(defun push-log (file message)
    (let ((pathname (log-path file)))
        (with-open-file (stream pathname :direction :output :element-type '(unsigned-byte 8) :if-exists :append))
        (write-line message)))
