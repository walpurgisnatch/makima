(in-package :cl-user)
(defpackage makima.sentry
  (:use :cl :makima.utils :makima.predicates)
  (:import-from :pero
                :write-log)
  (:export :run-all-checks))

(in-package :makima.sentry)

(defparameter *watchers* (make-hash-table :test 'equalp))

(defclass watcher ()
  ((name      :initarg :name      :accessor name)
   (target    :initarg :target    :accessor target)
   (interval  :initarg :interval  :accessor interval :initform 60)
   (predicate :initarg :predicate :accessor predicate)
   (handlers  :initarg :handlers  :accessor handlers)
   (records   :initarg :previous  :reader   records)
   (once      :initarg :once      :accessor once :initform nil)))

;; all data associated with stored records
(defclass record ()
  ((id        :initarg :id        :reader id)
   (value     :initarg :value     :reader value)
   (previous  :initarg :previous  :reader previous)
   (timestamp :initarg :timestamp :reader timestamp)))

(defmethod print-object ((obj watcher) stream)
  (print-unreadable-object (obj stream :type t)
    (with-accessors ((name name)) obj
      (format stream "~a" name))))

(defmethod print-object ((obj record) stream)
  (print-unreadable-object (obj stream :type t)
    (with-accessors ((id id) (value value) (timestamp timestamp)) obj
      (format stream "~a ~a ~a" id value timestamp))))

;; records utils
(defun make-record (&key id value previous)
  (make-instance 'record :id id :value value :previous previous :timestamp (get-universal-time)))

(defmethod create-record ((watcher watcher) value)
  (let* ((last (last-record watcher))
         (last-id (id last))
         (last-value (value last)))
    (make-record :id (1+ last-id) :value value :previous last-value)))

(defmethod get-record ((watcher watcher) index)
  (let ((records (records watcher)))
    (elt records (- (length records) index 1))))

(defmethod last-record ((watcher watcher))
  (car (records watcher)))

(defmethod last-record-value ((watcher watcher))
  (value (last-record watcher)))

(defmethod push-record ((record record) (watcher watcher))
  (with-slots (records) watcher
    (push record records)))

;; watcher utils

;; predicate works
(defgeneric predicate-args (watcher)
  (:documentation "default arguments used for predicate"))

(defmethod predicate-args ((watcher watcher))
  (with-accessors ((target target) (predicate predicate)) watcher
    (let ((last-value (last-record-value watcher)))
      (apply #'list last-value target (cdr predicate)))))

(defmethod check ((watcher watcher))
  (with-accessors ((predicate predicate)) watcher
    (apply (makima-function predicate) (predicate-args watcher))))

;; handlers works
(defmethod parse-arg (arg (watcher watcher))
  (if (makima-varp arg)
      (funcall (makima-var arg) watcher)
      arg))

(defmethod handler-args (handler (watcher watcher))
  (reverse (map 'list #'(lambda (arg) (parse-arg arg watcher)) (cdr handler))))

(defmethod handle (handlers (watcher watcher))
  (loop for handler in handlers do
        (apply (makima-function handler)
               (handler-args handler watcher))))

;; TODO define macro for checking and handling

(defun reset-table ()
  (setf *pages* (make-hash-table :test 'equalp)))
