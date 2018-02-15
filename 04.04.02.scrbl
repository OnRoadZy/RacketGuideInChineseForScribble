;04.04.02.scrbl
;4.4.2 声明可选（optional）参数
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "declaring-optional-arguments"]{声明可选（optional）参数}

不只是标识符，一个@racket[lambda]表的参数（不仅是剩余参数）可以用标识符和缺省值指定：

@specform/subs[
(lambda gen-formals
  body ...+)
([gen-formals (arg ...)
              rest-id
              (arg ...+ . rest-id)]
 [arg arg-id
      [arg-id default-expr]])
]{}

表的参数@racket[[arg-id default-expr]]是可选的。当参数不在应用程序中提供，@racket[_default-expr]产生默认值。@racket[_default-expr]可以引用任何前面的@racket[_arg-id]，并且下面的每个@racket[_arg-id]也必须应该有一个默认值。
@defexamples[
(define greet
  (lambda (given [surname "Smith"])
    (string-append "Hello, " given " " surname)))

(greet "John")
(greet "John" "Doe")
]

@def+int[
(define greet
  (lambda (given [surname (if (equal? given "John")
                              "Doe"
                              "Smith")])
    (string-append "Hello, " given " " surname)))

(greet "John")
(greet "Adam")
]