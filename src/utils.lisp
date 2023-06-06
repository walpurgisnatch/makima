(in-package :cl-user)
(defpackage :makima.utils
  (:use :cl)
  (:export :shell
           :pathname-as-directory
           :merge-with-dir
           :mkdir
           :entry-exist
           :sethash
           :hash-page
           :parse-float
           :predicate-function
           :predicate-args))

(in-package :makima.utils)

(defmacro list-or-car (&body body)
  `(let ((data ,@body))
     (if (cdr data)
         data
         (car data))))

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

(defun parse-float (string)
  (declare (optimize (speed 3) (safety 2)))
  (when (numberp string)
    (return-from parse-float string))
  (list-or-car
    (let ((*read-eval* nil))
      (with-input-from-string (stream string)
        (loop for number = (read stream nil nil)
              while (and number (numberp number)) collect number)))))

(defun predicate-function (predicate)
  (symbol-function (intern (string-upcase (car predicate)) 'makima)))

(defun predicate-args (content predicate)
  (cons content (cdr predicate)))

;; (defun hash-page (page)
;;   (ironclad:byte-array-to-hex-string
;;    (ironclad:digest-sequence
;;     :md5
;;     (ironclad:ascii-string-to-byte-array page))))

