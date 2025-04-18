(defpackage makima.charts
  (:use :cl :postmodern :makima.utils))

(in-package :makima.charts)

(defclass chart ()
  ((id          :col-type integer    :col-identity t       :reader id)
   (name        :col-type string     :initarg :name        :accessor name)
   (watchers    :col-type string[]   :initarg :watchers    :accessor watchers)
   (type        :col-type string     :initarg :type        :accessor type)
   (description :col-type (or string db-null) :initform nil
                                     :initarg :description :accessor description)
   (duration    :col-type string     :initarg :duration    :accessor duration :initform "24h")
   (styles      :col-type string     :initarg :styles      :accessor styles))
  (:metaclass dao-class)
  (:keys id)
  (:table-name charts))

(defmethod print-object ((obj chart) stream)
  (print-unreadable-object (obj stream :type t)
    (with-accessors ((id id) (name name) (watchers watchers) (type type)) obj
      (format stream "~a: [~a] ~a | ~a" id name watchers type))))

(defun make-chart (&key name watchers type description duration styles)
  (make-dao 'chart :name name :watchers watchers :type type :description description
                   :duration duration :styles styles))

