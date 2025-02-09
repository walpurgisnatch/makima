(defsystem "makima"
  :version "0.6.1"
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
               "jonathan"
               "file-attributes")
  :components ((:module "src"
                :components
                ((:file "daemon")
                 (:file "utils")
                 (:file "file-utils" :depends-on ("utils"))
                 (:file "db-utils" :depends-on ("utils"))
                 (:file "shared" :depends-on ("utils"))
                 (:file "sentry" :depends-on ("shared"));
                 (:file "sentry-dao" :depends-on ("sentry"))
                 (:file "sentry-functions" :depends-on ("sentry"))
                 (:file "predicates" :depends-on ("sentry-functions"))
                 (:file "handlers" :depends-on ("sentry-functions"))
                 (:file "html-watcher" :depends-on ("sentry"))
                 (:file "api-watcher" :depends-on ("sentry"))
                 (:file "dao-parser" :depends-on ("html-watcher" "api-watcher"))
                 (:file "heart" :depends-on ("sentry"))
                 (:file "makima" :depends-on ("heart" "daemon"))))
               (:module "server"
                :components
                ((:file "server")
                 (:file "sentry-controller" :depends-on ("server")))))
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
                 (:file "html-watcher" :depends-on ("server" "main"))
                 (:file "api-watcher" :depends-on ("server" "main"))
                 (:file "dao" :depends-on ("html-watcher")))))
  :perform (test-op (o c) (symbol-call :fiveam '#:run! (find-symbol* :makima :makima/tests/main))))
