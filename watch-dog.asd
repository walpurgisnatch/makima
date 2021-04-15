(defsystem "watch-dog"
  :version "0.1.0"
  :author "Walpurgisnatch"
  :license "MIT"
  :depends-on ("stepster")
  :components ((:module "src"
                :components
                ((:file "watch-dog"))))
  :description ""
  :in-order-to ((test-op (test-op "watch-dog/tests"))))
