(import (for-syntax :drewc/gsf/glib) :std/foreign
        :drewc/gsf/glib :std/srfi/13)
(export substg->string substg-test substg->char* char*->string input-size)

(begin-glib-ffi (substg->char* char*->string g-free substg-test input-size)

  (c-declare #<<END-C


#include <gsf/gsf.h>
#include <glib/gi18n.h>
#include <glib/gstdio.h>
#include <gio/gio.h>
#include <locale.h>
#include <string.h>
#include <errno.h>

static const char *
substg_to_utf8_string (GsfInput *input)
{
  guint8  const *data;
  GsfOutput *iconv, *master;
  size_t len;
  GString *str;
  char *ret;

  master = gsf_output_memory_new ();

  iconv = gsf_output_iconv_new (master, "UTF-8", "UTF-16LE");

  if (!gsf_input_copy (input, iconv)) {
    g_warning ("error reading ?");
    return;
  }

  gsf_input_seek (input, 0, G_SEEK_SET);
  gsf_output_close(iconv);
  gsf_output_close(master);

  len = gsf_output_size(master);
  data = gsf_output_memory_get_bytes (GSF_OUTPUT_MEMORY(master));
  str = g_string_new_len (data, len);

  ret = g_string_free(str, FALSE);

  return ret;
}

static void* _identity_ (void* i)
 { return i; };


END-C
)

(define-c-GObject GsfInput #f)
(define substg->char* (c-lambda (GsfInput*) (pointer char #f) "____return((char*)substg_to_utf8_string(____arg1));"))
(define char*->string (c-lambda ((pointer char)) UTF-8-string "___return((char *) ___arg1);"))
(define g-free (c-lambda ((pointer void)) void "g_free"))


(define input-size (c-lambda (GsfInput*) size_t "gsf_input_size"))
 (def (substg->string input)
   (let* ((char* (substg->char* input))
          (str (char*->string char*)))
     (begin0 (string-delete (cut char=? <> #\return) str) (g-free char*))))
