(import (for-syntax :drewc/gsf/glib) :std/foreign :drewc/gsf/glib)
(export input? input=? input-name input-container input-size
        input-read-u8 input-tell input-seek write-input-bytes
        G_SEEK_SET G_SEEK_CUR G_SEEK_END input-byte-position)

(begin-glib-ffi (input? input=? input-name
                        input-container input-size
                        input_read_u8 input-tell input-seek
                        G_SEEK_SET G_SEEK_CUR G_SEEK_END write_input_bytes)

  (c-declare #<<END-C

#include <gsf/gsf.h>
#include <glib/gi18n.h>
#include <glib/gstdio.h>
#include <gio/gio.h>
#include <locale.h>
#include <string.h>
#include <errno.h>

int input_read_u8(GsfInput *input) {

    guint8 const *data;
    int ret;
    gsf_off_t start_offset, remaining;

    start_offset = gsf_input_tell (input);

    remaining = gsf_input_remaining (input);

    if (remaining == 0) {
      return -1;
    }
    if (NULL == (data = gsf_input_read (input, 1, NULL))) {
      g_warning("Error reading from input: gsf_input_read = NULL");
      gsf_input_read (input, 0, NULL);
      gsf_input_seek (input, start_offset, G_SEEK_SET);
      return -1;
    }

    ret = *data;
    gsf_input_read (input, 0, NULL);
    return ret;
}
END-C
)
  (c-define (write-unsigned-int8 int port) (unsigned-int8 scheme-object)
            void "write_u8" "static"
   (write-u8 int port)
   #f)
  (c-declare #<<END-C
guint64 write_input_bytes(GsfInput *input, size_t n,  ___SCMOBJ port) {

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
      write_u8(*(data + i), port);
      ++count;
    }

    gsf_input_read (input, 0, NULL);
    return count;
}
END-C
)
  (define-c-GObject GsfInput #f)
  (define-c-GObject GsfInfile (GsfInput GsfInfile-nonfree))
  (c-define-type GsfInfile-nonfree* (pointer "GsfInfile"))
  (define %input? (c-lambda (GsfInput*) bool "GSF_IS_INPUT"))
  (define (input? thing) (and (foreign? thing) (%input? thing)))
  (define (input=? x y)
    (and (input? x) (input? x)
         (or (= (foreign-address x) (foreign-address y))
           (and (equal? (input-name x) (input-name y))
              (input=? (input-container x) (input-container y))))))
  (define input-name (c-lambda (GsfInput*) char-string "___return((char *) gsf_input_name (___arg1));"))
  (define input-container (c-lambda (GsfInput*) GsfInfile-nonfree* "gsf_input_container"))
  (define input-size (c-lambda (GsfInput*) size_t "gsf_input_size"))
  (define input_read_u8 (c-lambda (GsfInput*) int "input_read_u8"))
  (define input-tell (c-lambda (GsfInput*) unsigned-int64 "gsf_input_tell"))
  
  (define input-seek
    (c-lambda (GsfInput* int int) bool
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
  (define write_input_bytes
    (c-lambda (GsfInput* size_t scheme-object) unsigned-int64
              "write_input_bytes")))

(def (input-read-u8 inp)
  (let (u8 (input_read_u8 inp)) (if (= -1 u8) (eof-object) u8)))

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

  (if (not position) (input-tell input)
      (let* ((whence-alist `((0 . ,G_SEEK_SET)
                             (1 . ,G_SEEK_CUR)
                             (2 . ,G_SEEK_END)))
             (new-whence (if (not whence) G_SEEK_SET (assget whence whence-alist))))
        (when (not new-whence)
          (error "No Whence? " whence-alist
                 " new whence " new-whence
                 " old whence " whence))
        (begin (input-seek input position new-whence)
               (input-tell input)))))
(def (write-input-bytes inp n: (n 1024) (port (current-output-port)))
  (write_input_bytes inp n port))
