(import (for-syntax :drewc/gsf/glib) :std/foreign
        :drewc/gsf/glib :std/srfi/13)
(export read-bytes-from-input input-tell input-seek input-byte-position)

(begin-glib-ffi (read-bytes-from-input input-tell input-seek G_SEEK_SET G_SEEK_CURR G_SEEK_END)

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
  (c-define (write-unsigned-int8 int port) (unsigned-int8 scheme-object)
            void "write_u8" "static"
   (write-u8 int port)
   #f)

  (c-declare #<<END-C
   guint64 scm_read_bytes_from_input(GsfInput *input, size_t n,  ___SCMOBJ port) {
   
       guint8 const *data;
       guint64 count = 0;
       size_t i;
       gsf_off_t start_offset, remaining;
   
       start_offset = gsf_input_tell (input);
       remaining = gsf_input_remaining (input);
   
       n = (n > remaining) ? remaining : n;
   
       if (NULL == (data = gsf_input_read (input, n, NULL))) {
         g_warning("Error reading from input: gsf_input_read = NULL");
         gsf_input_read (input, 0, NULL);
         gsf_input_seek (input, start_offset, G_SEEK_SET);
         return 0;
       }
   
       for (i = 0; i < n; ++i) {
         write_u8 (*(data + i), port);
         count++;
       }
   
       gsf_input_read (input, 0, NULL);
       return count;
   }

END-C
)
  (define input-tell (c-lambda (GsfInput*) unsigned-int64 "gsf_input_tell"))
  
  (define input-seek
    (c-lambda (GsfInput* size_t int) bool
              "gsf_input_seek"))
  
  ;; https://developer.gnome.org/glib/2.62/glib-IO-Channels.html#GSeekType
  ;; enum GSeekType
  ;; An enumeration specifying the base position for a g_io_channel_seek_position() operation.
  
  ;; Members
  ;; G_SEEK_CUR the current position in the file.
  ;; G_SEEK_SET the start of the file.
  ;; G_SEEK_END the end of the file.
  
  (define-const G_SEEK_CUR)
  (define-const G_SEEK_SET)
  (define-const G_SEEK_END)

  (define read-bytes-from-input
    (c-lambda (GsfInput* size_t scheme-object) unsigned-int64
              "scm_read_bytes_from_input")))



;; When called with a single argument these procedures return the byte position
;; where the next I/O operation would take place in the file attached to the
;; given port (relative to the beginning of the file).

;; When called with two or three arguments, the byte position for subsequent I/O
;; operations on the given port is changed to position, which must be an exact
;; integer.

;; When whence is omitted or is 0, the position is relative to the beginning of
;; the file.

;; When whence is 1, the position is relative to the current byte position of
;; the file.

;; When whence is 2, the position is relative to the end of the file. The return
;; value is the new byte position.

;; On most operating systems the byte position for reading and writing of a
;; given bidirectional port are the same. -

;; --http://www.iro.umontreal.ca/~gambit/doc/gambit.html#I_002fO-and-ports

(def (input-byte-position input (position #f) (whence #f))
  (def whence-alist `((0 . ,G_SEEK_SET)
                      (1 . ,G_SEEK_CURR)
                      (2 . ,G_SEEK_END)))
  (let (whence (if (not whence) G_SEEK_SET (assget whence-alist whence)))
    (if (not position) (input-tell input)
        (begin (input-seek input position whence)
               (input-tell input)))))

(import (for-syntax :drewc/gsf/glib) :std/foreign
        :drewc/gsf/glib :std/srfi/13)
(export read-bytes-from-input input-tell input-seek input-byte-position)

(begin-glib-ffi (read-bytes-from-input input-tell input-seek G_SEEK_SET G_SEEK_CURR G_SEEK_END)

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
  (c-define (write-unsigned-int8 int port) (unsigned-int8 scheme-object)
            void "write_u8" "static"
   (write-u8 int port)
   #f)

  (c-declare #<<END-C
   guint64 scm_read_bytes_from_input(GsfInput *input, size_t n,  ___SCMOBJ port) {
   
       guint8 const *data;
       guint64 count = 0;
       size_t i;
       gsf_off_t start_offset, remaining;
   
       start_offset = gsf_input_tell (input);
       remaining = gsf_input_remaining (input);
   
       n = (n > remaining) ? remaining : n;
   
       if (NULL == (data = gsf_input_read (input, n, NULL))) {
         g_warning("Error reading from input: gsf_input_read = NULL");
         gsf_input_read (input, 0, NULL);
         gsf_input_seek (input, start_offset, G_SEEK_SET);
         return 0;
       }
   
       for (i = 0; i < n; ++i) {
         write_u8 (*(data + i), port);
         count++;
       }
   
       gsf_input_read (input, 0, NULL);
       return count;
   }

END-C
)
  (define input-tell (c-lambda (GsfInput*) unsigned-int64 "gsf_input_tell"))
  
  (define input-seek
    (c-lambda (GsfInput* size_t int) bool
              "gsf_input_seek"))
  
  ;; https://developer.gnome.org/glib/2.62/glib-IO-Channels.html#GSeekType
  ;; enum GSeekType
  ;; An enumeration specifying the base position for a g_io_channel_seek_position() operation.
  
  ;; Members
  ;; G_SEEK_CUR the current position in the file.
  ;; G_SEEK_SET the start of the file.
  ;; G_SEEK_END the end of the file.
  
  (define-const G_SEEK_CUR)
  (define-const G_SEEK_SET)
  (define-const G_SEEK_END)

  (define read-bytes-from-input
    (c-lambda (GsfInput* size_t scheme-object) unsigned-int64
              "scm_read_bytes_from_input")))



;; When called with a single argument these procedures return the byte position
;; where the next I/O operation would take place in the file attached to the
;; given port (relative to the beginning of the file).

;; When called with two or three arguments, the byte position for subsequent I/O
;; operations on the given port is changed to position, which must be an exact
;; integer.

;; When whence is omitted or is 0, the position is relative to the beginning of
;; the file.

;; When whence is 1, the position is relative to the current byte position of
;; the file.

;; When whence is 2, the position is relative to the end of the file. The return
;; value is the new byte position.

;; On most operating systems the byte position for reading and writing of a
;; given bidirectional port are the same. -

;; --http://www.iro.umontreal.ca/~gambit/doc/gambit.html#I_002fO-and-ports

(def (input-byte-position input (position #f) (whence #f))
  (def whence-alist `((0 . ,G_SEEK_SET)
                      (1 . ,G_SEEK_CURR)
                      (2 . ,G_SEEK_END)))
  (let (whence (if (not whence) G_SEEK_SET (assget whence-alist whence)))
    (if (not position) (input-tell input)
        (begin (input-seek input position whence)
               (input-tell input)))))
