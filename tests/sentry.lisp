(defpackage makima/tests/sentry
  (:use :cl
        :makima.utils
        :makima.sentry
        :makima.predicates
        :makima.handlers
        :makima/tests/main
        :fiveam)
  (:export :test-sentry))

(in-package :makima/tests/sentry)

(def-suite* sentry
  :in makima
  :description "Default watcher tests")

(defun read-file (file)
  (string-trim '(#\Newline) (alexandria:read-file-into-string file)))

(defun out-content (test)
  (cl-ppcre:scan-to-strings test (read-file "~/.makima-out")))

(defun write-line-to (file &optional line)
   (with-open-file (stream file :direction :output :if-exists :supersede :if-does-not-exist :create)
    (write-line (or line "nil") stream)))

(defparameter *test-var* "100")
(defparameter test-watcher nil)

(test init
  (set '*test-var* "100")
  (write-line-to "~/.makima-out")
  (setf test-watcher
        (make-watcher
         :name "test"
         :target '*test-var*
         :parser #'symbol-value
         :handlers (list
                    (make-handler :predicate `(in-content "watcher-parse-target" "123") :recordp t :once t)
                    (make-handler :predicate '(content-updated "watcher-last-record-value" "watcher-parse-target") :actions '((write-line-to "~/.makima-out" "watcher-last-record-value")))
                    (make-handler :recordp t :actions '((write-line-to "~/.makima-out" "watcher-last-record-value")))))))

(test basic-test
  (let ((args '("watcher-name" "counter" "watcher-parse-target" "0" "watcher-target")))
    (is (equal '("test" "counter" "100" "0" *test-var*) (parse-args args test-watcher)))
    (is (= (fcall `(+ ,counter 5) test-watcher) 5))
    (is (string= (fcall '(concatenate string "kek" "wpek") test-watcher) "kekwpek"))
    (is (string= (fcall '(concatenate string "watcher-name" "-case") test-watcher) "test-case"))))

(test handler-test
  (let ((handler1 (car (handlers test-watcher)))
        (handler2 (cadr (handlers test-watcher)))
        (handler3 (caddr (handlers test-watcher))))
    (is (and (recordp handler1) (once handler1)))
    (handle handler1 test-watcher)
    (is (string= "100" (current-value test-watcher)))
    (is (null (last-record-value test-watcher)))
    (set '*test-var* "123")
    (handle handler1 test-watcher t)
    (is (string= "123" (current-value test-watcher)))
    (is (= 1 (length (records test-watcher))))
    (is (string= "123" (last-record-value test-watcher)))
    (set '*test-var* "180")
    (is (out-content "nil"))
    (handle handler2 test-watcher)
    (is (string= "123" (last-record-value test-watcher)))
    (is (out-content "123"))
    (handle handler3 test-watcher t)
    (is (string= "180" (last-record-value test-watcher)))
    (is (out-content "180"))))

(test report-test
  (setf test-watcher
        (make-watcher
         :name "test"
         :target '*test-var*
         :parser #'symbol-value
         :handlers (list
                    (make-handler :predicate `(in-content "watcher-current-value" "123") :recordp t :once t)
                    (make-handler :predicate '(content-updated "watcher-last-record-value" "watcher-current-value") :actions '((write-line-to "~/.makima-out" "watcher-last-record-value")))
                    (make-handler :recordp t :actions '((write-line-to "~/.makima-out" "watcher-last-record-value"))))))
  (set '*test-var* "123")
  (report test-watcher)
  (is (<= (- (get-universal-time) (timestamp test-watcher)) 3))
  (is (= 1 (length (records test-watcher))))
  (is (string= "123" (last-record-value test-watcher)))
  (is (out-content "123")))
