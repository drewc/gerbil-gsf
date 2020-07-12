(import :std/sugar :std/format :std/text/csv :std/srfi/13 :drewc/gsf/test/lmdb)


(def ms-oxprop-csv::type (make-struct-type 'ms-oxprop-csv #f 14 'ms-oxprop-csv [] #f #f))

(def (ms-oxprop-csv . fields)
  (apply make-struct-instance ms-oxprop-csv::type fields))

(def ms-oxprop-csv-name (make-struct-field-accessor ms-oxprop-csv::type 0))
(def ms-oxprop-csv-id (make-struct-field-accessor ms-oxprop-csv::type 1))
(def ms-oxprop-csv-type-name (make-struct-field-accessor ms-oxprop-csv::type 2))
(def ms-oxprop-csv-type-id (make-struct-field-accessor ms-oxprop-csv::type 3))
(def ms-oxprop-csv-area (make-struct-field-accessor ms-oxprop-csv::type 8))

(def (ms-oxprop-csv-key prop (type-only? #f))
  (let* ((id (ms-oxprop-csv-id prop))
         (tid (ms-oxprop-csv-type-id prop))
         (tdrop (if (equal? tid "") tid (string-drop tid 2)))
         (key (string-append (if (equal? id "") id (string-drop id 2))
                             tdrop)))
    (if (equal? key "") #f (if type-only? tdrop key))))

(def ms-oxprop-db (lmdb-open-db lmdb-env "ms-oxprop"))

(defstruct ms-oxprop
  (name id type type-id area) transparent: #t)


(def (ms-oxprop-db-put! txn csv-line)
  (let* ((csv (apply ms-oxprop-csv csv-line))
         (prop (list
                (string->symbol (ms-oxprop-csv-name csv))
                (ms-oxprop-csv-id csv)
                (string->symbol (ms-oxprop-csv-type-name csv))
                (ms-oxprop-csv-type-id csv)
                (ms-oxprop-csv-area csv)))
         (key (ms-oxprop-csv-key csv))
         (type-key (ms-oxprop-csv-key csv #t))
         (val (with-output-to-string "" (cut write prop))))
    (when (string? key)
      (if (< 0 (string-length type-key))
        (lmdb-put txn ms-oxprop-db type-key (ms-oxprop-csv-type-name csv)))
      (try
       (lmdb-put txn ms-oxprop-db key val)
       (catch (e)
         (displayln "Error: " (error-message e) key val)
         (error "Error: " (error-message e) key val))))))

(def (ms-oxprop-db-get txn key)
  (let (v (lmdb-get txn ms-oxprop-db key))
    (if (not v) #f
        (let (v (with-input-from-u8vector v read))
          (if (pair? v)
            (apply make-ms-oxprop v)
            v)))))


(def (upsert-oxprops (csv "var/ms-oxprops-2020-05-25.csv"))
  (call-with-input-file csv
    (lambda (port) (read-line port)
       (call-with-transaction
        (lambda (txn)
          (let up ((line (read-csv-line port)))
            (if (null? line) (eof-object)
                (begin (ms-oxprop-db-put! txn line)
                       (up (read-csv-line port))))))))))
