(import (for-syntax :drewc/gsf/glib) :std/foreign :drewc/gsf/glib)
(export open-infile infile?
        infile-num-children
        infile-child-by-name
        infile-child-by-index
        infile-children)

(begin-glib-ffi (open-infile infile? infile-num-children infile-child-by-name 
                             infile-child-by-index)

  (c-declare #<<END-C

#include <gsf/gsf.h>
#include <glib/gi18n.h>
#include <glib/gstdio.h>
#include <gio/gio.h>
#include <locale.h>
#include <string.h>
#include <errno.h>

static GsfInfile *
open_infile (char const *filename)
{
  GsfInfile *infile;
  GError *error = NULL;
  GsfInput *src;
  char *display_name;

  src = gsf_input_stdio_new (filename, &error);
  if (error) {
    display_name = g_filename_display_name (filename);
    g_printerr (_("%s: Failed to open %s: %s\n"),
          g_get_prgname (),
          display_name,
          error->message);
    g_free (display_name);
    return NULL;
  }

  infile = gsf_infile_msole_new (src, NULL);
  if (infile) {
    g_object_unref (src);
    return infile;
  }

  infile = gsf_infile_zip_new (src, NULL);
  if (infile) {
    g_object_unref (src);
    return infile;
  }

  infile = gsf_infile_tar_new (src, NULL);
  if (infile) {
    g_object_unref (src);
    return infile;
  }

  display_name = g_filename_display_name (filename);
  g_printerr (_("%s: Failed to recognize %s as an archive\n"),
        g_get_prgname (),
        display_name);
  g_free (display_name);

  g_object_unref (src);
  return NULL;
}
END-C
)
  (define-c-GObject GsfInput #f)
  (define-c-GObject GsfInfile (GsfInput))
  (define open-infile (c-lambda (char-string) GsfInfile* "open_infile"))
  (define infile? (c-lambda (GsfInput*) bool "GSF_IS_INFILE"))
  (define infile-num-children
    (c-lambda (GsfInfile*) int "gsf_infile_num_children"))
  (define infile-child-by-index
    (c-lambda (GsfInfile* int) GsfInput* "gsf_infile_child_by_index"))
  (define infile-child-by-name (c-lambda (GsfInfile* char-string) GsfInput* "gsf_infile_child_by_name")))

(def (infile-children inf)
  (let (num (infile-num-children inf))
    (cond ((= num -1) #f)
          ((= num 0) [])
          (else
           (let infc ((n 0))
             (cons (infile-child-by-index inf n)
                   (if (= (1- num) n) []
                       (infc (+ 1 n)))))))))
