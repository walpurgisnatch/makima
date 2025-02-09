(in-package :cl-user)
(defpackage :makima.utils
  (:use :cl :postmodern)
  (:export :carlast
           :string-starts-with
           :entry-exist
           :sethash
           :make-hash
           :parse-float
           :makima-function
           :watcher-var
           :watcher-varp
           :hours-to-sec

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

(defun carlast (x)
  (car (last x)))

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

(defun parse-float (str)
  (declare (optimize (speed 3) (safety 2)))
  (when (numberp str)
    (return-from parse-float str))
  (let* ((cleaned (remove-if-not (lambda (c) (or (digit-char-p c) (char= c #\.))) str))
         (number (read-from-string cleaned nil nil)))
    (if (numberp number) number nil)))

(defun makima-function (str)
  (symbol-function (intern (string-upcase str) 'makima)))

(defun watcher-var (var)
  "Cut off watcher- part"
  (subseq var 8))

(defun watcher-varp (string)
  (when (stringp string)
      (string-starts-with string "watcher-")))

(defun hours-to-sec (x)
  (* x 3600))

