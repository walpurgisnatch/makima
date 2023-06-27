(defsystem "makima"
  :version "0.1.0"
  :author "Walpurgisnatch"
  :license "MIT"  
  :description "Monitoring system"
  :depends-on ("stepster"
               "pero"
               "local-time"
               "usocket"
               "cl-ppcre")
  :components ((:module "src"
                :serial t
                :components
                ((:file "daemon")                 
                 (:file "utils")
                 (:file "heart")
                 (:file "predicates")
                 (:file "handlers")
                 (:file "system-watcher")
                 (:file "html-watcher")
                 (:file "sentry")
                 (:file "makima"))))
  :in-order-to ((test-op (test-op "makima/tests"))))

(defsystem "makima/tests"
  :depends-on ("fiveam"
               "ningle"
               "clack"
               "jonathan"
               "stepster"
               "makima")
  :components ((:module "tests"
                :components
                ((:file "main")
                 (:file "html-watcher" :depends-on ("main" "server"))
                 (:file "server" :depends-on ("data"))
                 (:file "data"))))
  :perform (test-op (o c) (symbol-call :fiveam '#:run! 'makima)))
