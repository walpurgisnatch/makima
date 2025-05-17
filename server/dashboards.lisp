(defpackage makima.dashboards
  (:use :cl :postmodern :makima.utils
   :makima.shared :makima.router :makima.charts))

(in-package :makima.dashboards)

(defclass dashboard ()
  ((id          :col-type integer    :col-identity t       :reader id)
   (name        :col-type string     :initarg :name        :accessor name  :unique t)
   (description :col-type (or string db-null) :initform nil
                                     :initarg :description :accessor description))
  (:metaclass dao-class)
  (:primary-key id)
  (:table-name dashboards))

(defclass widget ()
  ((id        :col-type integer :col-identity t     :reader id)
   (dashboard :col-type integer :initarg :dashboard :accessor dashboard)
   (chart     :col-type integer :initarg :chart     :accessor chart)
   (order     :col-type integer :initarg :order     :accessor order)
   (width     :col-type integer :initarg :width     :accessor width)
   (height    :col-type integer :initarg :height    :accessor height))
  (:metaclass dao-class)
  (:primary-key id)
  (:table-name widgets))

(ensure-tables-exists '(dashboard row widget chart))

(defmethod print-object ((obj dashboard) stream)
  (print-unreadable-object (obj stream :type t)
    (with-accessors ((id id) (name name) (description description)) obj
      (format stream "~a: ~a | ~a" id name description))))

(defmethod print-object ((obj widget) stream)
  (print-unreadable-object (obj stream :type t)
    (with-accessors ((id id) (dashboard dashboard) (order order) (row row)) obj
      (format stream "~a: in ~a [~a] row: ~a" id dashboard order row))))

(defun make-dashboard (&key name description)
  (make-dao 'dashboard :name name :description description))

(defun make-widget (&key dashboard order width height row)
  (make-dao 'widget :dashboard dashboard :order order :width width
                    :height height))

(defroute "/dashboards" :get ()
  (ss:pack-to-json '(id name description)
     (loop for d in (select-dao 'dashboard)
           collect (object-data d (id name description)))))

(defroute "/dashboards" :post (|name| |description|)
  (make-dashboard :name |name| :description |description|)
  "ok")

(defroute "/dashboards/:dashboard" :get (dashboard)
  (ss:pack-to-json '(name description)
                   (object-data
                       (car (select-dao 'dashboard (:= 'name dashboard)))
                       (name description))))

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
  (select-dao 'widgets))

(defroute "/widgets" :post (|dashboard| |chart| |order| |width| |height|)
  (make-widget :dashboard |dashboard| :chart |chart| :order |order|
               :width |width| :height |height|))

