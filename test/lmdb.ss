(import :std/db/lmdb :std/sugar )
(export (import: :std/db/lmdb) lmdb-env call-with-transaction)

(def lmdb-env (lmdb-open "ms-oxprops"))

(def (call-with-transaction fn)
  (let (txn (lmdb-txn-begin lmdb-env))
    (try
     (begin0 (fn txn)
       (lmdb-txn-commit txn))
     (catch (e) (lmdb-txn-abort txn)
            (displayln (error-message e))
            (raise e)))))
