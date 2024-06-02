(defsystem "makima"
  :version "0.2.5"
  :author "Walpurgisnatch"
  :license "MIT"  
  :description "Monitoring system"
  :depends-on ("stepster"
               "alexandria"
               "pero"
               "local-time"
               "usocket"
               "cl-ppcre"
               "ironclad"
               "postmodern"
               "clack"
               "ningle"
               "jonathan")
  :components ((:module "src"
                :components
                ((:file "daemon")
                 (:file "utils")
                 (:file "file-utils" :depends-on ("utils"))
                 (:file "db-utils" :depends-on ("utils"))
                 (:file "shared" :depends-on ("utils"))
                 (:file "predicates" :depends-on ("shared"))
                 (:file "handlers" :depends-on ("shared"))
                 (:file "sentry" :depends-on ("predicates" "handlers"))
                 (:file "sentry-dao" :depends-on ("sentry"))
                 (:file "html-watcher" :depends-on ("sentry"))
                 (:file "heart" :depends-on ("sentry"))
                 (:file "makima" :depends-on ("heart" "daemon")))))
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
                 (:file "data")
                 (:file "sentry" :depends-on ("main"))
                 (:file "server" :depends-on ("data"))
                 (:file "html-watcher" :depends-on ("server" "main")))))
  :perform (test-op (o c) (symbol-call :fiveam '#:run! 'makima)))
