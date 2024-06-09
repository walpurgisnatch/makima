(in-package :makima.sentry)

(defclass common-functions ()
  ((id        :col-type integer  :col-identity t    :reader id)
   (handler   :col-type (or integer db-null)
                                 :initarg :handler  :accessor func-handler)
   (name      :col-type string   :initarg :name     :accessor func-name)
   (args      :col-type string[] :initarg :args     :accessor func-args)
   (persist   :col-type boolean  :initarg :persist  :accessor persist :initform nil))
  (:metaclass dao-class))

(defclass predicate (common-functions) ()
  (:metaclass dao-class)
  (:keys id)
  (:table-name predicates))

(defclass action (common-functions) ()
  (:metaclass dao-class)
  (:keys id)
  (:table-name actions))

(defmethod print-object ((obj common-functions) stream)  
  (print-unreadable-object (obj stream :type t)
    (with-accessors ((id id) (name func-name) (args func-args) (persist persist)) obj
      (format stream "~a: ~a ~a ~:[~;| persistent~]" id name args persist))))

(defmethod fcall ((func common-functions) (watcher watcher))
  (apply (makima-function (func-name func))
         (parse-args (func-args func) watcher)))

(defun make-func (type name args &optional (persist nil))
  (let ((name (string-downcase (string name)))
        (args (coerce args 'vector)))
    (id (make-dao type :name name :args args :persist persist))))

(defun create-func (type list)
  (make-func type (car list) (cdr list)))

(defun create-actions (actions)
  (map 'vector (lambda (action) (create-func 'action action)) actions))

(defun update-func-handler (table id handler)
  (let ((func (get-dao table id)))
    (setf (func-handler func) handler)
    (update-dao func)))

(defmethod dao-make-handler (&key name predicate actions (recordp nil) (once nil))
  (let* ((predicate-id (create-func 'predicate predicate))
         (actions-ids (create-actions actions))
         (handler-id (id (make-dao 'handler :name name
                                            :predicate predicate-id
                                            :actions actions-ids
                                            :recordp recordp :once once))))
    (update-func-handler 'predicate predicate-id handler-id)
    (loop for action-id across actions-ids
          do (update-func-handler 'action action-id handler-id))
    handler-id))

(defun dao-make-watcher (&key name target parser (interval 60) handlers)
  (save-watcher
   (make-dao 'watcher :name name :target target :parser parser
                      :interval interval :handlers handlers)))

(defmethod deserialize-handler ((handler handler))
  (with-accessors ((predicate predicate) (actions actions)) handler
    (let ((predicate-obj (get-dao 'predicate predicate))
          (actions-obj (select-objects-from-array 'action actions)))
      (setf predicate predicate-obj)
      (setf actions actions-obj)
      handler)))

(defmethod deserialize-handlers ((watcher watcher))
  (with-accessors ((handlers handlers)) watcher
    (let ((handlers-obj (select-objects-from-array 'handler handlers)))
      (setf handlers (mapcar #'deserialize-handler handlers-obj)))))

(defun deserialize-parser (watcher)
  (with-accessors ((parser parser)) watcher
    (setf parser (symbol-function (intern (string-upcase parser) 'makima)))))

