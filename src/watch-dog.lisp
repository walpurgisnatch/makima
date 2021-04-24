(defpackage watch-dog
  (:use :cl)
  (:import-from :utils
   :mkdir
   :sethash)  
  (:import-from :stepster
   :download-page)
  (:import-from :logger
                :directory-setup
   :push-log)
  (:import-from :watch-dog.hasher
                :hash))

(in-package :watch-dog)

(defvar *table* (make-hash-table))
(defvar *root-dir* nil)
(defvar *pages-dir* nil)

(defun setup (dir)
    (progn (logger-setup dir '(errors "errors.log") '(updates "updates.log"))
           (setf (mkdir "pages/" dir))
           (setf *root-dir* dir)))

(defun download-all-pages (urls)
    (loop for url in urls do
      (handler-case
          (let ((filename (concatenate 'string *pages-dir* url)))
              (download-page url filename))
        (error (e) (push-log 'errors (format nil "~&Error while downloading image [~a]~%~a~%" image e))))))

(defun check-all-pages (pages)
    (loop for page in pages do
      (let ((page-hash (updated page)))
          (when page-hash
              (record-update page page-hash)))))

(defun updated (page)
    (let ((page-hash (hash page)))
        (if (= page-hash (gethash *table* page))
            nil
            page-hash)))

(defun record-update (page page-hash)
    (let ((filename (concatenate 'string *pages-dir* page))
          (time (local-time:format-timestring nil (local-time:now) :format '(:day "." :month "." :year))))
        (sethash page page-hash *table*)
        (download-page page filename)
        (push-log 'updates (format nil "[~a] ~a was updated" time page))))
