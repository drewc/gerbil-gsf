(import (for-syntax :drewc/gsf/glib) :std/foreign :drewc/gsf/glib)
(export open-archive)

(begin-glib-ffi (open-archive)

  (c-declare #<<END-C


#include <gsf/gsf.h>
#include <glib/gi18n.h>
#include <glib/gstdio.h>
#include <gio/gio.h>
#include <locale.h>
#include <string.h>
#include <errno.h>

static GsfInfile *
open_archive (char const *filename)
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

  infile = gsf_infile_zip_new (src, NULL);
  if (infile) {
    g_object_unref (src);
    return infile;
  }

  infile = gsf_infile_msole_new (src, NULL);
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
(define-c-GObject GsfInput (GsfInfile))
(define-c-GObject GsfInfile)
(define open-archive (c-lambda (char-string) GsfInfile* "open_archive")))
