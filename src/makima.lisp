(defpackage makima
  (:use :cl)
  (:import-from :utils
                :mkdir
                :sethash
                :hash-page)
  (:import-from :stepster
                :download-page)
  (:import-from :pero
                :logger-setup
                :write-log))

(in-package :makima)

(defvar *table* (make-hash-table))
(defvar *conf* nil)
(defvar *root-dir* nil)
(defvar *pages-dir* nil)

(defstruct data
  url
  type
  date
  before
  after)

(defun setup (dir)
  (setf *root-dir* dir)
  (setf *conf* (concatenate 'string dir "/targets.conf"))
  (setf *pages-dir* (concatenate 'string dir "/pages"))
  (logger-setup (concatenate 'string dir "/logs")
                '("errors" (download-error "Error while downloading page [~a]~%~a~%"))
                '("changes" (changes "~a~% was changed"))))

(defun download-all-pages (urls)
  (loop for url in urls do
    (handler-case
        (let ((filename (concatenate 'string *pages-dir* url)))
          (download-page url filename))
      (error (e) (write-log 'download-error url e)))))

(defun check-all-pages (pages)
  (loop for page in pages do
    (let ((page-hash (updated page)))
      (when page-hash
        (record-update page page-hash)))))

(defun updated (page)
  (let ((page-hash (hash-page page)))
    (if (= page-hash (gethash *table* page))
        nil
        page-hash)))

(defun record-update (page page-hash)
  (let ((filename (concatenate 'string *pages-dir* page)))
    (sethash page page-hash *table*)
    (download-page page filename)
    (write-log 'changes page)))
