(defpackage makima.charts
  (:use :cl :postmodern :makima.utils :makima.router)
  (:import-from :makima.sentry
                :get-watcher
                :records
                :value
                :timestamp)
  (:import-from :makima.sentry-controller
                :records-json)
  (:export :chart           
           :get-chart
           :make-chart
           :get-chart-fields
           :get-chart-data
           :get-watchers-records
           :update-chart))

(in-package :makima.charts)

(defclass chart ()
  ((id          :col-type integer    :col-identity t       :reader id)
   (name        :col-type string     :initarg :name        :accessor name)
   (watchers    :col-type text[]     :initarg :watchers    :accessor watchers)
   (chart-type  :col-type string     :initarg :chart-type  :accessor chart-type)
   (description :col-type (or string db-null) :initform nil
                                     :initarg :description :accessor description)
   (duration    :col-type integer    :initarg :duration    :accessor duration :initform 86400000)
   (refresh     :col-type integer    :initarg :refresh     :accessor refresh  :initform 10000)
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

(defun update-chart (chart &key name watchers type description
                             duration refresh styles)
  (let ((chart (get-chart chart)))
    (with-accessors ((name_ name) (watchers_ watchers) (type_ chart-type)
                     (description_ description) (duration_ duration)
                     (refresh_ refresh) (styles_ styles)) chart
        (setf name_ name
              watchers_ (coerce watchers 'vector)
              type_ type
              description_ description
              duration_ duration 
              refresh_ refresh
              styles_ styles)
        (update-dao chart))))

(defun get-chart (id)
  (get-dao 'chart id))

(defun get-chart-fields (id)
  (let ((chart (get-chart id)))
    (conlist
     (object-to-plist chart
                      '((id |chartId|) name watchers (chart-type |chartType|) description duration refresh))
     `(:|styles| ,(jonathan:parse (format nil "~a" (styles chart)))))))

(defun get-chart-data (id)
  (let ((chart (get-chart id)))
    (jonathan:to-json
     (loop for watcher across (watchers chart)
           collect `(:|watcher| ,watcher
                      :|records| ,(watcher-records
                                   (get-watcher watcher)
                                   (/ (duration chart) 1000)))))))

(defun get-watchers-records (watchers duration)
  (jonathan:to-json
     (loop for watcher in watchers
           collect `(:|watcher| ,watcher
                      :|records| ,(watcher-records
                                   (get-watcher watcher)
                                   (/ duration 1000))))))

(defun watcher-records (watcher &optional for)
  (mapcar #'(lambda (obj) (object-to-plist obj '(value timestamp)))
          (records watcher :for for)))

