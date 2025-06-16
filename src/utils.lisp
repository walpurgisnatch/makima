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
           :select-objects-from-array
           :time-to-s
           :timestamp-for-time
           :object-data
           :json-data-of
           :get-json
           :arg
           :object-to-plist))

(in-package :makima.utils)

(defun object-to-plist (obj slot-names)
  (loop for slot-name in slot-names
        append (list (intern (string-downcase (string slot-name)) :keyword)
                     (slot-value obj slot-name))))

(defmacro object-data (obj slots &body body)
  `(with-accessors ,(loop for slot in slots
                          collect (list slot slot))
       ,obj
     (list ,@slots ,@body)))

(defmacro json-data-of (objl keys vals &body body)
  `(ss:pack-to-json ',keys (mapcar #'(lambda (obj) (object-data obj ,vals ,@body)) ,objl)))

(defmacro list-or-car (&body body)
  `(let ((data ,@body))
     (if (cdr data)
         data
         (car data))))

(defun arg (list key)
  (cdr (find key list :key #'car :test #'string=)))

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

(defun time-to-s (time-str)
  (let ((total 0)
        (pos 0)
        (len (length time-str)))
    (loop
      while (< pos len)
      do
      (multiple-value-bind (num new-pos)
          (parse-integer time-str :start pos :junk-allowed t)
        (when (null num) (return total))        
        (if (< new-pos len)
            (let ((suffix (char time-str new-pos)))
              (incf total 
                    (* num
                       (case suffix
                         (#\y 31536000)
                         (#\w 604800)
                         (#\d 86400)
                         (#\h 3600)
                         (#\m 60)
                         (#\s 1)
                         (t 0))))
              (setf pos (1+ new-pos)))
            (progn
              (incf total num)
              (setf pos new-pos)))))
    total))

(defun timestamp-for-time (time-str)
  (format nil "~a" (- (get-universal-time) (time-to-s time-str))))

(defun get-json (keys list)
  ;;TODO
  (+ 1 1))
