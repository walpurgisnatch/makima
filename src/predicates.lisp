(defpackage makima.predicates
  (:use :cl :makima.utils :makima.sentry)
  (:export :*predicates-list*
           :content-updated
           :in-content
           :more-than
           :more-or-equal-than
           :less-then
           :less-or-equal-than
           :rised-for
           :dropped-for))

(in-package :makima.predicates)

(defparameter *predicates-list* nil)

(defmacro string-as-float-comparsion (fun &rest args)
  `(,fun ,@(loop for arg in args collect `(parse-float ,arg))))

(defmacro defpred (name args type doc &body body)
  `(eval-when (:load-toplevel)     
     (unless (find ',name *predicates-list* :key #'cadr)
       (push (list ',type ',name ,(coerce args 'vector) ,doc) *predicates-list*))
     (defun ,name (watcher ,@args) ,@body)))

(defun percent-change (list)
  (if (>= (length list) 2)
    (let ((new (car list))
          (old (carlast list)))
      (if (zerop old)
          0
          (* 100 (/ (- new old) (float old)))))
    nil))

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

(defpred content-updated () general
    "Content updated"
  (not (equal (last-record-value watcher)
              (current-value watcher))))

(defpred in-content (regex) string
    "Provided substring exists in regex"
  (cl-ppcre:scan-to-strings regex (current-value watcher)))

(defpred more-than (arg) number-comparsion
    "Value more than provided argument"
  (string-as-float-comparsion > (current-value watcher) arg))

(defpred more-or-equal-than (arg) number-comparsion
    "Value more or equal"
  (string-as-float-comparsion >= (current-value watcher) arg))

(defpred less-than (arg) number-comparsion
    "Value less than"
  (string-as-float-comparsion < (current-value watcher) arg))

(defpred less-or-equal-than (arg) number-comparsion
    "Value less or equal"
  (string-as-float-comparsion <= (current-value watcher) arg))

(defpred rised-for (hours amount) number-comparsion
    "Value has rised for amount in hours"
  (let* ((count (/ (hours-to-sec hours) (interval watcher)))
         (values (mapcar #'parse-float (last-records-values watcher count)))
         (change (percent-change values)))
    (and change (> change amount))))

(defpred dropped-for (hours amount) number-comparsion
    "Value has dropped for amount in hours"
  (let* ((count (/ (hours-to-sec hours) (interval watcher)))
         (values (mapcar #'parse-float (last-records-values watcher count)))
         (change (percent-change values)))
    (and change (< change amount))))
