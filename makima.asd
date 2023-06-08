(defsystem "makima"
  :version "0.1.0"
  :author "Walpurgisnatch"
  :license "MIT"
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
  :description "Monitoring system")
