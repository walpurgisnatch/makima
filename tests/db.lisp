(defpackage makima/tests/db
  (:use :cl
        :makima.utils
        :makima.shared
        :makima.sentry
        :makima/tests/main
        :postmodern
        :fiveam)
  (:export :db-tests))

(in-package :makima/tests/db)

(def-suite* db-tests
  :in makima
  :description "DB tests")

(defclass country ()
    ((name :col-type string :initarg :name
            :reader country-name)
    (inhabitants :col-type integer :initarg :inhabitants
                :accessor country-inhabitants)
    (sovereign :col-type (or db-null string) :initarg :sovereign
                :accessor country-sovereign))
    (:metaclass dao-class)
    (:keys name))

(test init
  (connect-toplevel "makima" "makima" "makima" "localhost")
  (execute (dao-table-definition 'country))
  (insert-dao (make-instance 'country :name "Croatia"
                                    :inhabitants 4400000)))

(test use-data
  (let ((croatia (get-dao 'country "Croatia")))
    (is (= 4400000 (country-inhabitants croatia)))
    (setf (country-inhabitants croatia) 4500000)
    (update-dao croatia))
  (is (= 4500000 (country-inhabitants (get-dao 'country "Croatia"))))
  (query (:drop-table 'country))
  (disconnect-toplevel))
