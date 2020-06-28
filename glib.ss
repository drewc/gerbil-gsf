(import :std/foreign (for-syntax :std/stxutil))
(export begin-glib-ffi)
(defsyntax (begin-glib-ffi stx)
  (def (prelude-macros)
    '(
      (define-macro (define-c-GType name . tags/free)
        (let* ((str (symbol->string name))
               (ptr (string->symbol (string-append str "*")))
               (ptr-tags (cond ((and (pair? tags/free) (list? (car tags/free)))
                                (cons ptr (car tags/free)))
                               ((and (pair? tags/free) (eq? #f (car tags/free)))
                                #f)
                               (else (list ptr))))
               (ptr-free (if (and (pair? tags/free)
                                (string? (last tags/free)))
                           (list (last tags/free))
                           '())))
        `(begin (c-define-type ,name ,str)
                (c-define-type ,ptr (pointer ,str ,ptr-tags ,@ptr-free)))))
      (define-macro (define-c-GObject name . tags)
        (let* ((str (symbol->string name))
               (ptr (string->symbol (string-append str "*")))
               (ptr-tags (cond ((and (pair? tags) (list? (car tags)))
                                (cons ptr (car tags)))
                               ((and (pair? tags) (eq? #f (car tags)))
                                #f)
                               (else (list ptr)))))
      
      
        `(begin (c-define-type ,name ,str)
                (c-define-type ,ptr (pointer ,str ,ptr-tags "gobj_free")))))
      ))
  (syntax-case stx ()
    ((_ exports body ...)
     (with-syntax (((macros ...) (prelude-macros)))
       #'(begin-ffi
          exports
          macros ...
          (c-declare "___SCMOBJ gobj_free(void *ptr);")
          (c-declare "#include <glib.h>")
          (define-c-GObject GObject #f)
          (define-const TRUE)
          (define-const FALSE)
         body ...
         (c-declare #<<END-C
#ifndef ___HAVE_GOBJ_FREE
#define ___HAVE_GOBJ_FREE
___SCMOBJ gobj_free (void *ptr)
{
 g_object_unref (ptr);
 return ___FIX (___NO_ERR);
}
#endif
END-C
))))))
