(in-package :makima.utils)

(defun table-name (table)
  (format nil "~as" (string-downcase (string table))))

(defun table-existp (table)
  (caar (query (format nil "select exists (select from information_schema.tables where table_name = '~a');" (table-name table)))))

(defun create-table (table)
  (unless (table-existp table)
    (execute (dao-table-definition table))))

(defun ensure-tables-exists (tables)
  (with-connection '("makima" "makima" "makima" "localhost")
    (loop for table in tables
          do (create-table table))))

(defun select-last (table table-name &key test)
  (car (query-dao table (:limit
                         (:order-by
                          (:select '* :from table-name
                           :where test)
                          (:desc 'id))
                         1))))

(defun select-objects-from-array (table array)
  (loop for item-id across array
        collect (get-dao table item-id)))


