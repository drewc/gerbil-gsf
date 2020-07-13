#!/usr/bin/env gxi
;; [[file:~/src/gerbil-gsf/test/test.org][No heading:1]]
(import :std/test)
(def repo-path (path-directory (this-source-file)))
(def testdir-path (path-expand "test/" repo-path))

(load (path-expand "doc/test-manual.ss" repo-path))

(current-directory testdir-path)
(set! test-gsf-root-path testdir-path)

(run-test-suite! test-gsf-manual)


(displayln testdir-path)
;; No heading:1 ends here
