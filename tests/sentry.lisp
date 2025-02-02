(defpackage makima/tests/sentry
  (:use :cl
        :postmodern
        :makima        
        :makima.utils
        :makima.sentry
        :makima.predicates
        :makima.handlers
        :makima/tests/main
        :fiveam)
  (:export :sentry))

(in-package :makima/tests/sentry)

(def-suite* sentry
  :in makima
  :description "Default watcher tests")

(defun read-file (file)
  (string-trim '(#\Newline) (alexandria:read-file-into-string file)))

(defun out-content (test)
  (cl-ppcre:scan-to-strings test (read-file "~/.makima-out")))

(defun write-line-to (watcher file &optional line)
  (declare (ignore watcher))
   (with-open-file (stream file :direction :output :if-exists :supersede :if-does-not-exist :create)
    (write-line (or line "nil") stream)))

(defparameter counter 0)
(defparameter *test-var* "100")
(defparameter test-watcher nil)

(test init
  (with-connection '("makimatest" "makima" "makima" "localhost")
    (setf counter 0)
    (set '*test-var* "100")
    (write-line-to '1 "~/.makima-out")
    (setf test-watcher
          (make-watcher
           :name "test"
           :target '*test-var*
           :parser #'symbol-value
           :handlers (handler-list
                      (:predicate `(in-content "123") :recordp t :once t)
                      (:predicate '(content-updated) :actions '((write-line-to "~/.makima-out" "watcher-last-record-value")))
                      (:recordp t :actions '((write-line-to "~/.makima-out" "watcher-last-record-value"))))))))

(test report-test
  (with-connection '("makimatest" "makima" "makima" "localhost")
    (set '*test-var* "123")
    (report test-watcher)
    (is (<= (- (get-universal-time) (timestamp test-watcher)) 3))
    (is (= 1 (length (records test-watcher))))
    (is (string= "123" (last-record-value test-watcher)))
    (is (out-content "123"))))

