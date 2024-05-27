(defpackage makima/tests/data
  (:use :cl)
  (:export :*pages-data*
           :*content-data*))

(in-package :makima/tests/data)


(defparameter *content-data*
  '("<html lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:fb=\"http://ogp.me/ns/fb#\">
      <head></head>
      <body>
        <div class=\"kekwpek\">
          <a class=\"link\" href=\"#\">10</a>
        </div>      
      </body>
    </html>"
    
    "<html lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:fb=\"http://ogp.me/ns/fb#\">
      <head></head>
      <body>
        <div class=\"kekwpek\">
          <a class=\"link\" href=\"#\">20</a>
        </div>      
      </body>
    </html>"

    "<html lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:fb=\"http://ogp.me/ns/fb#\">
      <head></head>
      <body>
        <div class=\"kekwpek\">
          <a class=\"link\" href=\"#\">33</a>
        </div>      
      </body>
    </html>"))

