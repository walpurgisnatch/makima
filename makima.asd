(defsystem "makima"
  :version "0.1.2"
  :author "Walpurgisnatch"
  :license "MIT"  
  :description "Monitoring system"
  :depends-on ("stepster"
               "alexandria"
               "pero"
               "local-time"
               "usocket"
               "cl-ppcre"
               "ironclad")
  :components ((:module "src"
                :serial t
                :components
                ((:file "daemon")
                 (:file "file-works")
                 (:file "utils")
                 (:file "heart")
                 (:file "predicates")
                 (:file "handlers")
                 (:file "sentry")
                 ;(:file "system-watcher")
                 ;(:file "files-watcher")
                 ;(:file "html-watcher")                 
                 (:file "makima"))))
  :in-order-to ((test-op (test-op "makima/tests"))))

(defsystem "makima/tests"
  :depends-on ("fiveam"
               "ningle"
               "clack"
               "jonathan"
               "pero"
               "alexandria"
               "stepster"
               "makima")
  :components ((:module "tests"
                :components
                ((:file "main")
                 (:file "sentry" :depends-on ("main"))
                 ;(:file "files-watcher" :depends-on ("main" "server"))
                 ;(:file "html-watcher" :depends-on ("main" "server"))
                 (:file "server" :depends-on ("data"))
                 (:file "data"))))
  :perform (test-op (o c) (symbol-call :fiveam '#:run! 'makima)))
