;;; Vector Genomes
(defmethod inds ((genome vector))
  (loop :for i :from 0 :to (1- (length genome)) collect i))

(defmethod ind ((genome vector) ind)
  (aref genome ind))

(defmethod (setf ind) (new (genome vector) ind)
  (setf (aref genome ind) new))


;;; Vector Methods
(defmethod copy ((genome vector))
  (copy-seq genome))

(defmethod size ((genome vector))
  (length genome))

(defmethod genome-average-keys ((genome vector) place)
  (let ((above (unless (= place (- (length genome) 1))
                 (aref genome (+ place 1))))
        (below (unless (= place 0)
                 (aref genome (- place 1))))
        (middle (aref genome place)))
    (dolist (key *genome-averaging-keys*)
      (let ((new (/ (apply #'+ (mapcar (lambda (el) (or (cdr (assoc key el)) 0))
                                       (list above below middle)))
                    3)))
        (if (assoc key (aref genome place))
            (setf (cdr (assoc key (aref genome place))) new)
            (push (cons key new) (aref genome place)))))
    genome))

(defmethod edit-distance ((a vector) (b vector))
  (levenshtein-distance a b :test #'equalp))

(defmethod insert ((genome vector) &key (good-key nil) (bad-key nil))
  (let ((dup (location genome good-key))
        (ins (location genome bad-key)))
    (values (cond
              ((> dup ins)
               (concatenate 'vector
                 (subseq genome 0 ins)
                 (vector (aref genome dup))
                 (subseq genome ins dup)
                 (subseq genome dup)))
              ((> ins dup)
               (concatenate 'vector
                 (subseq genome 0 dup)
                 (subseq genome dup ins)
                 (vector (aref genome dup))
                 (subseq genome ins)))
              (:otherwise
               (concatenate 'vector
                 (subseq genome 0 dup)
                 (vector (aref genome dup))
                 (subseq genome dup))))
            (list dup ins))))

(defmethod cut ((genome vector) &key (good-key nil) (bad-key nil))
  (declare (ignorable good-key))
  (let ((ind (location genome bad-key)))
    (values (concatenate 'vector
              (subseq genome 0 ind)
              (subseq genome (+ 1 ind)))
            ind)))

(defmethod swap ((genome vector) &key (good-key nil) (bad-key nil))
  (let* ((a (location genome good-key))
         (b (location genome bad-key))
         (temp (aref genome a)))
    (setf (aref genome a) (aref genome b))
    (setf (aref genome b) temp)
    (values genome (list a b))))

(defmethod crossover ((a vector) (b vector))
  (let ((point (random (min (length a) (length b)))))
    (values (concatenate 'vector (subseq a 0 point) (subseq b point))
            point)))