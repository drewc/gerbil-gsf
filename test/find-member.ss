(import (for-syntax :drewc/gsf/glib) :std/foreign :drewc/gsf/glib)
(export find-member)

(begin-glib-ffi (find-member)

  (c-declare #<<END-C


#include <gsf/gsf.h>
#include <glib/gi18n.h>
#include <glib/gstdio.h>
#include <gio/gio.h>
#include <locale.h>
#include <string.h>
#include <errno.h>

static GsfInput *
find_member (GsfInfile *arch, char const *name)
{
  char const *slash = strchr (name, '/');

  if (slash) {
    char *dirname = g_strndup (name, slash - name);
    GsfInput *member;
    GsfInfile *dir;

    member = gsf_infile_child_by_name (arch, dirname);
    g_free (dirname);
    if (!member)
      return NULL;
    dir = GSF_INFILE (member);
    member = find_member (dir, slash + 1);
    g_object_unref (dir);
    return member;
  } else {
    return gsf_infile_child_by_name (arch, name);
  }
}
END-C
)
(define-c-GObject GsfInput (GsfInfile))
(define-c-GObject GsfInfile (GsfInput))
(define find-member (c-lambda (GsfInfile* char-string) GsfInput* "find_member")))
