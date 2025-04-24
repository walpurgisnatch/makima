(defpackage makima.seeder
  (:use :cl :postmodern :makima.sentry :makima.shared)
  (:export :seed))

(in-package :makima.seeder)

(defun create-watchers (&optional (count 5))
  (loop for i from 1 to count
        do (create-watcher :name (format nil "test-~a" i)
                           :target "11"
                           :parser #'parse-integer
                           :interval 10000000
                           :handlers (handler-list
                                     (:recordp t)))))

(defun create-records (&optional (count 10))
  (loop for watcher being the hash-keys of *watchers*
        do (loop for i from 1 to count
                 do (make-dao 'record :id i :value i
                                      :watcher watcher
                                      :timestamp (+ (* i 300) (get-universal-time))))))

(defun clear-records ()
  (query "delete from records"))

(defun seed ()
  (with-connection (db-credentials)
    (unless (get-watcher "test-1")
      (create-watchers)
      (create-records))))

