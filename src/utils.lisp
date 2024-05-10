(in-package :cl-user)
(defpackage :makima.utils
  (:use :cl :makima.file-works)
  (:export :string-starts-with
           :entry-exist
           :sethash
           :make-hash
           :parse-float
           :makima-function
           :makima-var
           :makima-varp))

(in-package :makima.utils)

(defmacro list-or-car (&body body)
  `(let ((data ,@body))
     (if (cdr data)
         data
         (car data))))

(defun string-starts-with (string x)
  (when (> (length string) (length x))
    (string-equal string x :end1 (length x))))

(defun entry-exist (key table)
  (nth-value 1 (gethash key table)))

(defun sethash (key value table)
  (setf (gethash key table) value))

(defun make-hash (string)
  (ironclad:byte-array-to-hex-string
   (ironclad:digest-sequence
    :md5
    (ironclad:ascii-string-to-byte-array string))))

(defun parse-float (string)
  (declare (optimize (speed 3) (safety 2)))
  (when (numberp string)
    (return-from parse-float string))
  (list-or-car
    (let ((*read-eval* nil))
      (with-input-from-string (stream string)
        (loop for number = (read stream nil nil)
              while (and number (numberp number)) collect number)))))

(defun makima-function (list)
  (symbol-function (intern (string-upcase (car list)) 'makima)))

(defun makima-var (var)
  "Cut off makima- part"
  (makima-function (subseq var 7)))

(defun makima-varp (string)
  (string-starts-with string "makima-"))
