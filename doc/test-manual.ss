(import :std/test :drewc/gsf :std/srfi/13 :std/text/utf16 :std/sugar)
;; (export test-gsf-manual test-gsf-root-path)
(def test-gsf-root-path  "/home/user/src/gerbil-gsf/test")

(def test-gsf-manual
  (test-suite
   "Testing GSF Manual"
  ;; [[file:~/src/gerbil-gsf/doc/manual.org::#gsf_storages_and_streams][]]
  (def msg (open-compound-file
            (path-expand "Outlook1.msg" test-gsf-root-path)))
  ;; ends here
  ;; [[file:~/src/gerbil-gsf/doc/manual.org::*Storage][]]
  (check (storage? msg) => #t)
  ;; ends here
  ;; [[file:~/src/gerbil-gsf/doc/manual.org::*Storage][]]
  (check (storage-children-count msg) => 85)
  ;; ends here
  ;; [[file:~/src/gerbil-gsf/doc/manual.org::#gsf_storages_and_streams][]]
  (check (infile? msg) => #t)
  ;; ends here
  ;; [[file:~/src/gerbil-gsf/doc/manual.org::*Storage][]]
  (check (storage? msg) => #t)
  ;; ends here
  ;; [[file:~/src/gerbil-gsf/doc/manual.org::*Storage][]]
  (check (storage-children-count msg) => 85)
  ;; ends here
  ;; [[file:~/src/gerbil-gsf/doc/manual.org::*Storage][]]
  (def first-child (storage-ref msg 0))
  (check (input? first-child) => #t)
  ;; ends here
  ;; [[file:~/src/gerbil-gsf/doc/manual.org::*Storage][]]
  (check (input-name first-child) => "__nameid_version1.0")
  ;; ends here
  ;; [[file:~/src/gerbil-gsf/doc/manual.org::*Storage][]]
  (check (input-name (storage-ref msg (input-name first-child)))
         => (input-name first-child))
  ;; ends here
  ;; [[file:~/src/gerbil-gsf/doc/manual.org::*Storage][]]
  (check (input=? (storage-ref msg 0) (storage-ref msg "__nameid_version1.0"))
         => #t)
  
  (check (input=? msg first-child) => #f)
  ;; ends here
  ;; [[file:~/src/gerbil-gsf/doc/manual.org::*Storage][]]
  (check (input=? msg (input-container first-child)) => #t)
  ;; ends here
  ;; [[file:~/src/gerbil-gsf/doc/manual.org::*Storage][]]
  (check (input-name msg) => #f)
  (check (input-container msg) => #f)
  ;; ends here
  ;; [[file:~/src/gerbil-gsf/doc/manual.org::*Storage][]]
  (def msg-children (storage-children msg))
  ;; ends here
  ;; [[file:~/src/gerbil-gsf/doc/manual.org::*Storage][]]
  (check (input=? (list-ref msg-children 2) (storage-ref msg 2))
         => #t)
  ;; ends here
  ;; [[file:~/src/gerbil-gsf/doc/manual.org::*Storage][]]
  (check (storage? first-child) => #t)
  (check (storage-children-count first-child) => 22)
  ;; ends here
  ;; [[file:~/src/gerbil-gsf/doc/manual.org::*Streams][]]
  (def msg-subject (storage-ref msg "__substg1.0_0037001F"))
  ;; ends here
  
  ;; [[file:~/src/gerbil-gsf/doc/manual.org::*Streams][]]
  (def msg-subject-first-byte (stream-read-u8 msg-subject))
  (check msg-subject-first-byte => 91)
  ;; ends here
  ;; [[file:~/src/gerbil-gsf/doc/manual.org::*Streams][]]
  (def msg-subject-rest-bytes
    (let (rb (cut stream-read-u8 msg-subject))
      (call-with-output-u8vector
       #u8() (lambda (p) (let lp ((byte (rb)))
                      (if (eof-object? byte) p
                          (begin (write-u8 byte p) (lp (rb)))))))))
  
  (check msg-subject-rest-bytes => #u8(0 69 0 88 0 84 0 93 0 32 0 82 0 101 0 58 0
  32 0 91 0 69 0 88 0 84 0 93 0 32 0 82 0 101 0 58 0 32 0 79 0 117 0 116 0 108 0
  111 0 111 0 107 0 32 0 46 0 109 0 115 0 103 0 32 0 102 0 105 0 108 0 101 0 115
  0))
  ;; ends here
  ))
