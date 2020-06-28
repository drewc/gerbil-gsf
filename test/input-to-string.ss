(import (for-syntax :drewc/gsf/glib) :std/foreign :drewc/gsf/glib)
(export input->string)

(begin-glib-ffi (input->string)

  (c-declare #<<END-C


#include <gsf/gsf.h>
#include <glib/gi18n.h>
#include <glib/gstdio.h>
#include <gio/gio.h>
#include <locale.h>
#include <string.h>
#include <errno.h>

static char *
  __GsfInput_to_string (GsfInput *input)
  {
    guint8 const *data;
    size_t len;
    GString *str;

   len = gsf_input_size (input);

    if (NULL == (data = gsf_input_read (input, len, NULL))) {
      g_warning ("error reading ?");
      return;
    }

    str = g_string_new_len (data, len);

    g_object_unref (G_OBJECT (input));

    return g_string_free(str, FALSE);
  }
END-C
)
(define-c-GObject GsfInput (GsfInfile))
(define-c-GObject GsfInfile)
(define input->string (c-lambda (GsfInput*) UTF-16-string "__GsfInput_to_string")))
