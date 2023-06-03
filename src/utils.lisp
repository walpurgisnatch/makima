(in-package :cl-user)
(defpackage :makima.utils
  (:use :cl)
  (:export :pathname-as-directory
           :mkdir
           :entry-exist
           :sethash
           :hash-page
           :merge-with-dir
           :shell))

(in-package :makima.utils)

(defun shell (&rest args)
  (uiop:run-program (format nil "~{~a~^ ~}" args) :output :string))

(defun component-present-p (value)
  (and value (not (eql value :unspecific))))

(defun directory-pathname-p  (p)
  (and
   (not (component-present-p (pathname-name p)))
   (not (component-present-p (pathname-type p)))
   p))

(defun pathname-as-directory (name)
  (let ((pathname (pathname name)))
    (when (wild-pathname-p pathname)
      (error "Can't reliably convert wild pathnames."))
    (if (not (directory-pathname-p name))
        (make-pathname
         :directory (append (or (pathname-directory pathname) (list :relative))
                            (list (file-namestring pathname)))
         :name      nil
         :type      nil
         :defaults pathname)
        pathname)))

(defun mkdir (dir &optional parent)
  (namestring (ensure-directories-exist
               (if parent
                   (merge-with-dir dir parent)
                   (pathname-as-directory dir)))))

(defun merge-with-dir (child parent)
  (merge-pathnames child (pathname-as-directory parent)))

(defun sethash (key value table)
  (setf (gethash key table) value))

(defun entry-exist (key table)
  (nth-value 1 (gethash key table)))

(defun hash-page (page)
  (ironclad:byte-array-to-hex-string
   (ironclad:digest-sequence
    :md5
    (ironclad:ascii-string-to-byte-array page))))

