(defsystem "makima"
  :version "0.1.0"
  :author "Walpurgisnatch"
  :license "MIT"
  :depends-on ("stepster"
               "pero"
               "local-time"
               "ironclad"
               "nail"
               "usocket"
               "cl-ppcre")
  :components ((:module "src"
                :serial t
                :components
                ((:file "daemon")
                 (:file "utils")
                 (:file "sentry")
                 (:file "makima"))))
  :description "Monitoring system"
  :in-order-to ((test-op (test-op "makima/tests"))))
