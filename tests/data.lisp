(defpackage makima/tests/data
  (:use :cl)
  (:export :*pages-data*
           :*content-data*))

(in-package :makima/tests/data)

(defparameter *pages-data* '("<html lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:fb=\"http://ogp.me/ns/fb#\"><head></head><body><script data-cookieconsent=\"ignore\" src=\"https://cdn.testone.com/site/js/three.min.bundle.js?1686689004\"></script>
<link href=\"https://cdn.testone.com/site/css/vendors.css?1686689004\" type=\"text/css\" rel=\"stylesheet\">
<link href=\"https://cdn.testone.com/site/css/app.css?1686689004\" type=\"text/css\" rel=\"stylesheet\">
<div class=\"react-app\" id=\"react-app\"></div><script data-cookieconsent=\"ignore\" src=\"https://cdn.testone.com/site/js/vendors.bundle.js?1686689004\"></script>
<script data-cookieconsent=\"ignore\" src=\"https://cdn.testone.com/site/js/app.bundle.js?1686689004\"></script>
</body></html>"
                 "<html lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:fb=\"http://ogp.me/ns/fb#\"><head></head><body><script data-cookieconsent=\"ignore\" src=\"https://cdn.testone.com/site/js/three.min.bundle.js?1686689004\"></script>
<link href=\"https://cdn.testone.com/site/css/vendors.css?1686689004\" type=\"text/css\" rel=\"stylesheet\">
<link href=\"https://cdn.testone.com/site/css/app.css?1686689004\" type=\"text/css\" rel=\"stylesheet\">
<div class=\"react-app\" id=\"react-app\"></div></body></html>"
                 "<html lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:fb=\"http://ogp.me/ns/fb#\"><head></head><body><script data-cookieconsent=\"ignore\" src=\"https://api.testone.com/site/js/three.min.bundle.js?1686689004\"></script>
<link href=\"https://api.testone.com/site/css/vendors.css?1686689004\" type=\"text/css\" rel=\"stylesheet\">
<link href=\"https://api.testone.com/site/css/app.css?1686689004\" type=\"text/css\" rel=\"stylesheet\">
<div class=\"react-app\" id=\"react-app\"></div></body></html>"))

(defparameter *content-data* '("<html lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:fb=\"http://ogp.me/ns/fb#\"><head></head><body><div class=\"statistics-updates di-b w100 mb8\">
  <a href=\"https://myanimelist.net/manga/109234/Jahy-sama_wa_Kujikenai\" class=\"fl-l di-ib mr8 image\">
    <img class=\" lazyloaded\" data-src=\"https://cdn.myanimelist.net/r/80x120/images/manga/2/206958.webp?s=22cc321048b12a74e1c515eb310d7b1d\" alt=\"Jahy-sama wa Kujikenai!\" style=\"image-rendering: inherit;\" src=\"https://cdn.myanimelist.net/r/80x120/images/manga/2/206958.webp?s=22cc321048b12a74e1c515eb310d7b1d\" width=\"40\">
  </a> <div class=\"data\">
    <a href=\"https://myanimelist.net/manga/109234/Jahy-sama_wa_Kujikenai\">Jahy-sama wa Kujikenai!</a>
    <div class=\"clearfix graph-content pt8\">
      <span class=\"fl-r fn-grey2\">Jun 10, 10:33 PM</span>
      <div class=\"graph fl-l\"><span class=\"graph-inner manga reading\" style=\"width:95px\"></span></div>
    </div>
    <div class=\"fn-grey2\">Reading<span class=\"text manga reading\">33</span>/?
       · Scored
      <span class=\"text manga reading score-label score-9\">9</span></div></div></div></body></html>"
                   
                   "<html lang=\"en\" xmlns=\"http://www.w3.org/1999/xhtml\" xmlns:fb=\"http://ogp.me/ns/fb#\"><head></head><body><div class=\"statistics-updates di-b w100 mb8\">
  <a href=\"https://myanimelist.net/manga/109234/Jahy-sama_wa_Kujikenai\" class=\"fl-l di-ib mr8 image\">
    <img class=\" lazyloaded\" data-src=\"https://cdn.myanimelist.net/r/80x120/images/manga/2/206958.webp?s=22cc321048b12a74e1c515eb310d7b1d\" alt=\"Jahy-sama wa Kujikenai!\" style=\"image-rendering: inherit;\" src=\"https://cdn.myanimelist.net/r/80x120/images/manga/2/206958.webp?s=22cc321048b12a74e1c515eb310d7b1d\" width=\"40\">
  </a> <div class=\"data\">
    <a href=\"https://myanimelist.net/manga/109234/Jahy-sama_wa_Kujikenai\">Jahy-sama wa Kujikenai!</a>
    <div class=\"clearfix graph-content pt8\">
      <span class=\"fl-r fn-grey2\">Jun 24, 10:12 PM</span>
      <div class=\"graph fl-l\"><span class=\"graph-inner manga reading\" style=\"width:95px\"></span></div>
    </div>
    <div class=\"fn-grey2\">Reading<span class=\"text manga reading\">39</span>/?
       · Scored
      <span class=\"text manga reading score-label score-9\">9</span></div></div></div></body></html>"))

