(in-package :cl-user)
(defpackage makima.sentry
  (:use :cl :postmodern :makima.utils :makima.predicates)
  (:import-from :pero
                :write-log)
  (:export :*watchers*
           :watcher
           :record
           :name
           :target
           :handlers
           :records
           :current-value
           :timestamp
           :predicate
           :actions
           :recordp
           :once
           :make-record
           :save-record
           :push-record
           :get-record
           :last-record
           :last-record-value
           :parse-arg
           :parse-args
           :make-handler
           :add-handler
           :fcall
           :handle
           :make-watcher
           :parse-target
           :report
           :interval-passed
           :create-watcher
           :clear-watchers))

(in-package :makima.sentry)

(defparameter *watchers* (make-hash-table :test 'equalp))

(defclass watcher ()
  ((name      :initarg :name      :accessor name)
   (target    :initarg :target    :accessor target)
   (parser    :initarg :parser    :accessor parser)
   (interval  :initarg :interval  :accessor interval :initform 60)
   (handlers  :initarg :handlers  :accessor handlers)
   (current   :initarg :current   :accessor current-value :initform nil)
   (timestamp :initarg :timestamp :accessor timestamp :initform nil)))

(defclass handler ()
  ((predicate :initarg :predicate :accessor predicate :initform #'content-updated)
   (actions   :initarg :actions   :accessor actions :initform nil)
   (recordp   :initarg :recordp   :accessor recordp :initform nil)
   (once      :initarg :once      :accessor once :initform nil)))

;; all data associated with stored records
(defclass record ()
  ((id        :col-type integer :initarg :id        :reader id)   
   (watcher   :col-type string  :initarg :watcher   :reader watcher)
   (value     :col-type string  :initarg :value     :reader value)
   (timestamp :col-type string  :initarg :timestamp :reader timestamp))
  (:metaclass dao-class)
  (:keys watcher id)
  (:table-name records))

(defmethod print-object ((obj watcher) stream)
  (print-unreadable-object (obj stream :type t)
    (with-accessors ((name name) (value current-value) (records records)) obj
      (format stream "~a: ~a | ~a " name value (length records)))))

(defmethod print-object ((obj handler) stream)
  (print-unreadable-object (obj stream :type t)
    (with-accessors ((predicate predicate) (recordp recordp)) obj
      (format stream "~a ~a" recordp predicate))))

(defmethod print-object ((obj record) stream)
  (print-unreadable-object (obj stream :type t)
    (with-accessors ((id id) (watcher watcher) (value value)) obj
      (format stream "~a: ~a | ~a" id watcher value))))

;; records utils
(defmethod save-record ((watcher watcher))
  (let ((last (last-record watcher))
        (watcher-name (name watcher))
        (value (current-value watcher)))1
    (if last
        (make-dao 'record :id (1+ (id last)) :value value :watcher watcher-name
                          :timestamp (get-universal-time))
        (make-dao 'record :id 0 :value value :watcher watcher-name
                          :timestamp (get-universal-time)))))

(defmethod records ((watcher watcher))
  (with-accessors ((watcher-name name)) watcher
    (select-dao 'record (:= 'watcher watcher-name))))

(defmethod get-record ((watcher watcher) index)
  (with-accessors ((watcher-name name)) watcher
    (get-dao 'record watcher-name index)))

(defmethod last-record ((watcher watcher))
  (with-accessors ((watcher-name name)) watcher
    (car (query-dao 'record
                    (:limit
                     (:order-by
                      (:select '* :from 'records
                       :where (:= 'watcher watcher-name))
                      (:desc 'id))
                     1)))))

(defmethod last-record-value ((watcher watcher))
  (let ((last (last-record watcher)))
    (when last (value (last-record watcher)))))

;; handler utils
(defmethod make-handler (&key predicate actions recordp once)
  (make-instance 'handler :predicate predicate :actions actions
                          :recordp recordp :once once))

(defmethod add-handler ((watcher watcher) &key predicate actions recordp once)
  (with-accessors ((handlers handlers)) watcher
    (let ((handler (make-handler :predicate predicate :actions actions
                                 :recordp recordp :once once)))
      (push handler handlers))))

(defmethod parse-arg (arg (watcher watcher))
  (if (watcher-varp arg)
      (funcall (watcher-var arg) watcher)
      arg))

(defmethod parse-args (list (watcher watcher))
  (map 'list #'(lambda (arg) (parse-arg arg watcher)) list))

(defmethod fcall (func (watcher watcher))
  (apply (makima-function (car func)) (parse-args (cdr func) watcher)))

;; main
(defun make-watcher (&key name target parser interval handlers)
  (make-instance 'watcher :name name :target target :parser parser
                          :interval interval :handlers handlers))

(defgeneric parse-target (watcher)
  (:documentation "Parse and return value from target"))

(defmethod parse-target ((watcher watcher))
  (with-accessors ((target target) (parse parser) (current current-value)) watcher
    (setf current (funcall parse target))))

(defmethod run-actions (actions (watcher watcher))
  (loop for action in actions
        do (fcall action watcher)))

(defmethod handle ((handler handler) (watcher watcher) &optional (savep nil))
  (with-accessors ((predicate predicate) (actions actions) (recordp recordp)) handler
    (when (or (null predicate) (fcall predicate watcher))
      (when (and recordp savep) (save-record watcher))
      (run-actions actions watcher)
      recordp)))

(defgeneric report (watcher)
  (:documentation "Parse target, update timestamp and run all handlers"))

(defmethod report ((watcher watcher))
  (with-accessors ((handlers handlers) (timestamp timestamp)) watcher
    (parse-target watcher)
    (setf timestamp (get-universal-time))
    (loop for handler in handlers
          with savep = t
          when (handle handler watcher savep)
            do (setf savep nil))))

(defmethod interval-passed (current (watcher watcher))
  (with-accessors ((last timestamp) (interval interval)) watcher
    (or (null last) (>= (- current last) interval))))

(defmethod create-watcher ((watcher watcher))
  (with-accessors ((name name)) watcher
    (sethash name watcher *watchers*)))

(defun clear-watchers ()
  (setf *watchers* (make-hash-table :test 'equalp)))
