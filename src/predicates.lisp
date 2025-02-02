(defpackage makima.predicates
  (:use :cl :makima.utils :makima.sentry)
  (:export :content-updated
           :in-content
           :more-than
           :more-or-equal-than
           :less-then
           :less-or-equal-than))

(in-package :makima.predicates)

(defmacro string-as-float-comparsion (fun &rest args)
  `(,fun ,@(loop for arg in args collect `(parse-float ,arg))))

(defmacro defpred (name args &body body)
  `(defun ,name (watcher ,@args) ,@body))

(defun time-is (&key month day hour min)
  (let ((result t))
    (multiple-value-bind
          (second current-min current-hour current-day current-month)
        (get-decoded-time)
      (when (or (and min (/= current-min min))
                (and hour (/= current-hour hour))
                (and day (/= current-day day))
                (and month (/= current-month month)))        
        (setf result nil)))
    result))

(defpred content-updated ()
  (not (equal (last-record-value watcher)
              (current-value watcher))))

(defpred in-content (regex)
  (cl-ppcre:scan-to-strings regex (current-value watcher)))

(defpred more-than (arg)
  (string-as-float-comparsion > (current-value watcher) arg))

(defpred more-or-equal-than (arg)
  (string-as-float-comparsion >= (current-value watcher) arg))

(defpred less-than (arg)
  (string-as-float-comparsion < (current-value watcher) arg))

(defpred less-or-equal-than (arg)
  (string-as-float-comparsion <= (current-value watcher) arg))
