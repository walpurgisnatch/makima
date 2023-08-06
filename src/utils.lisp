(in-package :cl-user)
(defpackage :makima.utils
  (:use :cl)
  (:export :pathname-as-directory
           :merge-with-dir
           :mkdir
           :entry-exist
           :sethash
           :hash-page
           :parse-float
           :predicate-function
           :predicate-args
           :handler-args
           :handler-args-test
           :makima-var
           :ls
           :upper-directory))

(in-package :makima.utils)

(defmacro list-or-car (&body body)
  `(let ((data ,@body))
     (if (cdr data)
         data
         (car data))))

(defun component-present-p (value)
  (and value (not (eql value :unspecific))))

(defun directory-pathname-p  (p)
  (and
   (not (component-present-p (pathname-name p)))
   (not (component-present-p (pathname-type p)))
   p))

(defun directory-wildcard (dir)
  (make-pathname
   :name :wild
   :type :wild
   :defaults (pathname-as-directory dir)))

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

(defun ls (&optional directory)
  (let ((dir (or directory ".")))
    (when (wild-pathname-p dir)
      (error "Wildcard not supported"))
    (directory (directory-wildcard dir))))

(defun upper-directory (&optional directory)
  (elt (nth-value 1 (cl-ppcre:scan-to-strings "(.*/).+$" (namestring (or directory (uiop/os:getcwd))))) 0))

(defun string-starts-with (string x)
  (when (> (length string) (length x))
    (string-equal string x :end1 (length x))))

(defun makima-var (var)
  "Cut off makima- part"
  (subseq var 7))

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
  (when (consp predicate) (setf predicate (car predicate)))
  (symbol-function (intern (string-upcase predicate) 'makima)))

(defun predicate-args (last new predicate)
  (remove-if #'null (concatenate 'list (list last new) (cdr predicate))))

(defun handler-args (handler record)
  (let ((result nil))
    (loop for arg in (cdr handler)
          if (string-starts-with arg "makima-")
            do (push (funcall (predicate-function (makima-var arg)) record) result)
          else do (push arg result))
    (reverse result)))

(defun hash-page (page)
  (ironclad:byte-array-to-hex-string
   (ironclad:digest-sequence
    :md5
    (ironclad:ascii-string-to-byte-array page))))

