(import (for-syntax :drewc/gsf/glib) :std/foreign :drewc/gsf/glib)
(export infile-children infile-num-children infile-child-by-index input-name)

(begin-glib-ffi (infile-num-children infile-child-by-index input-name)

  (c-declare #<<END-C


#include <gsf/gsf.h>
#include <glib/gi18n.h>
#include <glib/gstdio.h>
#include <gio/gio.h>
#include <locale.h>
#include <string.h>
#include <errno.h>
END-C
) 

  (define-c-GObject GsfInput (GsfInfile))
  (define-c-GObject GsfInfile (GsfInput))
  (define input-name (c-lambda (GsfInput*) UTF-8-string "gsf_input_name"))
  (define infile-num-children
    (c-lambda (GsfInfile*) int "gsf_infile_num_children"))
  (define infile-child-by-index
    (c-lambda (GsfInfile* int) GsfInput* "gsf_infile_child_by_index"))
)
(def (infile-children inf)
  (let (num (infile-num-children inf))
    (cond ((= num -1) #f)
          ((= num 0) [])
          (else
           (let infc ((n 0))
             (cons (infile-child-by-index inf n)
                   (if (= (1- num) n) []
                       (infc (+ 1 n)))))))))
