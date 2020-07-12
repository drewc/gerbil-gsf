(import :std/sugar :std/text/csv :std/srfi/13
        :drewc/gsf/test/lmdb :drewc/gsf/test/ms-oxprop-db
        :drewc/gsf/test/input-to-string :drewc/gsf/test/list-children)
(export substg-value-as-string input-substg? input-ms-oxprop-key input-ms-oxprop)
(def (input-substg? input)
  (string-prefix? "__substg" (input-name input)))
(def (input-ms-oxprop-key input)
  (let (name (input-name input))
    (try (substring/shared name (1+ (string-index-right name #\_)))
         (catch (_) name))))
(def (input-ms-oxprop input)
  (let* ((key (input-ms-oxprop-key input))
         (val (when key (call-with-transaction (cut ms-oxprop-db-get <> key)))))
    (or val
        ;; We don't have anything. Let's make a new one.
        (let* ((key (when key (string-take-right key 4)))
               (val (when key (call-with-transaction (cut ms-oxprop-db-get <> key))))
               (name (input-name input)))
          (make-ms-oxprop name #f val (string-append "0x" key) "Unknown")))))
(def (substg-value-as-string input)
  (and (input-substg? input)
       (let* ((oxprop (input-ms-oxprop input))
              (ptype (ms-oxprop-type oxprop)))
         (case ptype
           ((PtypString) (input->string input))
           (else (void))))))
