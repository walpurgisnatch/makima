(defpackage makima.charts
  (:use :cl :postmodern :makima.utils :makima.router)
  (:import-from :makima.sentry
                :get-watcher)
  (:import-from :makima.sentry-controller
                :records-json)
  (:export :chart           
           :get-chart
           :make-chart
           :get-chart-data
           :get-watchers-records))

(in-package :makima.charts)

(defclass chart ()
  ((id          :col-type integer    :col-identity t       :reader id)
   (name        :col-type string     :initarg :name        :accessor name)
   (watchers    :col-type text[]     :initarg :watchers    :accessor watchers)
   (chart-type  :col-type string     :initarg :chart-type  :accessor chart-type)
   (description :col-type (or string db-null) :initform nil
                                     :initarg :description :accessor description)
   (duration    :col-type string     :initarg :duration    :accessor duration :initform "24h")
   (refresh     :col-type string     :initarg :refresh     :accessor refresh  :initform "1m")
   (styles      :col-type string     :initarg :styles      :accessor styles))
  (:metaclass dao-class)
  (:keys id)
  (:table-name charts))

(defmethod print-object ((obj chart) stream)
  (print-unreadable-object (obj stream :type t)
    (with-accessors ((id id) (name name) (watchers watchers) (type chart-type)) obj
      (format stream "~a: [~a] ~a | ~a" id name watchers type))))

(defun make-chart (&key name watchers type description duration refresh styles)
  (id (make-dao 'chart :name name :watchers (coerce watchers 'vector) :chart-type type
                :description description :duration duration :refresh refresh :styles styles)))

(defun get-chart (id)
  (object-to-plist (get-dao 'chart id)
      '(id name watchers chart-type description duration refresh styles)))

(defun get-chart1 (id)
  (get-dao 'chart id))

(defun get-chart-data (id)
  (records-json (get-watcher
                 (elt (watchers (get-chart1 id)) 0))
                50))

(defun get-watchers-records (watchers)
  (records-json (get-watcher (car watchers)) 50))


