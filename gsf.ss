package: drewc
(import :drewc/gsf/infile :drewc/gsf/input)
(export open-compound-file
        storage? storage-name storage-children-count storage-children storage-ref

       input? input=? input-name input-container

       stream? stream-read-u8 stream-byte-position 

       infile?)

(def open-compound-file open-infile)

(def (storage? thing) (and (input? thing) (infile? thing)
                           (<= 0 (infile-num-children thing))))

(def storage-name input-name)
(def storage-children infile-children)

(def storage-children-count infile-num-children)

(def (storage-ref s . refs)
  (let (child
        ((if (string? (car refs)) infile-child-by-name infile-child-by-index)
         s (car refs)))
    (if (not child) #f
        (if (null? (cdr refs)) child
            (apply storage-ref child (cdr refs))))))

(def (stream? thing)
  (and (input? thing)
       (not (storage? thing))))

(def stream-read-u8 input-read-u8)
(def stream-byte-position input-byte-position)
(def stream-size input-size)
(def write-stream-bytes write-input-bytes)

(def (stream-read-u8vector strm n: (n 1024) (bytes #u8()))
  (call-with-output-u8vector
   bytes (lambda (p) (write-stream-bytes strm n: n p))))

(def (stream-read-all-as-u8vector strm (buffsize 8192))
  (let ((givr (cut write-stream-bytes strm n: buffsize <>)))
    (call-with-output-u8vector
     #u8() (lambda (p)
             (let lp ((n (givr p)))
               (if (> buffsize n) p
                   (lp (givr p))))))))
