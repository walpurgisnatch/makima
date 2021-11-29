(defsystem "makima"
  :version "0.1.0"
  :author "Walpurgisnatch"
  :license "MIT"
  :depends-on ("stepster"
               "pero"
               "local-time"
               "ironclad")
  :components ((:module "src"
                :serial t
                :components
                ((:file "utils")
                (:file "makima"))))
  :description "Monitoring system"
  :in-order-to ((test-op (test-op "makima/tests"))))
