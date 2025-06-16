(defpackage makima.dashboards
  (:use :cl
        :postmodern
        :makima.utils
        :makima.shared
        :makima.router
        :makima.charts))

(in-package :makima.dashboards)

(defclass dashboard ()
  ((id          :col-type integer    :col-identity t       :reader dashboard-id)
   (name        :col-type string     :initarg :name        :accessor name  :unique t)
   (description :col-type (or string db-null) :initform nil
                                     :initarg :description :accessor description))
  (:metaclass dao-class)
  (:primary-key id)
  (:table-name dashboards))

(defclass widget ()
  ((id          :col-type integer :col-identity t       :reader widget-id)
   (dashboard   :col-type string  :initarg :dashboard   :accessor dashboard)
   (widget-type :col-type string  :initarg :widget-type :accessor widget-type)
   (chart       :col-type integer :initarg :chart       :accessor chart)
   (order       :col-type integer :initarg :order       :accessor order)
   (width       :col-type integer :initarg :width       :accessor width)
   (height      :col-type integer :initarg :height      :accessor height))
  (:metaclass dao-class)
  (:primary-key id)
  (:table-name widgets))

(ensure-tables-exists '(dashboard widget chart))

(defroute "/dashboards" :get ()
  (ss:pack-to-json '(id name description)
     (loop for d in (select-dao 'dashboard)
           collect (object-data d (dashboard-id name description)))))

(defroute "/dashboards" :post (|name| |description|)
  (make-dashboard :name |name| :description |description|)
  "ok")

(defroute "/dashboards/:dashboard" :get (dashboard)
  (let ((dashboard-obj (car (select-dao 'dashboard (:= 'name dashboard)))))
         (jonathan:to-json (list :|name| (name dashboard-obj)
                                 :|description| (description dashboard-obj)
                                 :|widgets| (select-widgets dashboard)))))

(defroute "/dashboards/:dashboard" :put (dashboard |name| |description|)
  (let ((dashboard-dao (car (select-dao 'dashboard (:= 'name dashboard)))))
    (when dashboard-dao
      (with-slots (name description) dashboard-dao
        (setf name |name|
              description |description|)
        (update-dao dashboard-dao))))
  "ok")

(defroute "/dashboards/:dashboard" :delete (dashboard)
  (let ((dashboard (car (select-dao 'dashboard (:= 'name dashboard)))))
    (when dashboard
      (delete-dao dashboard)))
  "ok")

(defroute "/dashboards/:dashboard/widgets" :get (dashboard)
  (jonathan:to-json (select-widgets dashboard)))

(defroute "/widgets" :post (|dashboard| |widgetType| |chartType| |name| |watchers|
                            |description| |duration| |refresh| |styles|)
  (make-widget :dashboard |dashboard| :widget-type |widgetType| :width 450 :height 450
               :chart-type |chartType| :name |name| :watchers |watchers| :styles |styles|
               :description |description| :duration |duration| :refresh |refresh|)
  "ok")

(defroute "/widgets/:widget/data" :get (widget) 
  (get-chart-data widget))

(defroute "/widgets/data" :post (|watchers|)
  (get-watchers-records |watchers|))

;; utils

(defmethod print-object ((obj dashboard) stream)
  (print-unreadable-object (obj stream :type t)
    (with-accessors ((id dashboard-id) (name name) (description description)) obj
      (format stream "~a: ~a | ~a" id name description))))

(defmethod print-object ((obj widget) stream)
  (print-unreadable-object (obj stream :type t)
    (with-accessors ((id widget-id) (dashboard dashboard) (order order)) obj
      (format stream "~a: in ~a [~a]" id dashboard order))))

(defun make-dashboard (&key name description)
  (make-dao 'dashboard :name name :description description))

(defun make-widget (&key dashboard width height widget-type name watchers
                      chart-type description duration refresh styles)
  (let ((order (calc-order dashboard))
        (chart (make-chart :name name
                           :watchers watchers
                           :type chart-type
                           :description description
                           :duration duration
                           :refresh refresh
                           :styles styles)))
    (make-dao 'widget :dashboard dashboard :order order :width width
                      :height height :widget-type widget-type :chart chart)))

(defun calc-order (dashboard)
  (length (select-dao 'widget (:= 'dashboard dashboard))))

(defun select-widgets (dashboard)
  (let ((widgets (select-dao 'widget (:= 'dashboard dashboard))))
    (loop for widget in widgets
          collect (concatenate 'list
                               (object-to-plist widget
                                                '(order width height widget-type))
                               (get-chart (chart widget))))))

