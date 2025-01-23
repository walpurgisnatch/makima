(in-package :cl-user)
(defpackage :makima.utils
  (:use :cl :postmodern)
  (:export :string-starts-with
           :entry-exist
           :sethash
           :make-hash
           :parse-float
           :makima-function
           :watcher-var
           :watcher-varp

           :mkdir
           :merge-with-dir
           :ls
           :upper-directory

           :create-table
           :select-last
           :select-objects-from-array))

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

(defun makima-function (str)
  (symbol-function (intern (string-upcase str) 'makima)))

(defun watcher-var (var)
  "Cut off watcher- part"
  (makima-function (subseq var 8)))

(defun watcher-varp (string)
  (when (stringp string)
      (string-starts-with string "watcher-")))


