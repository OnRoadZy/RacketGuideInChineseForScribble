;04.05.scrbl
;4.5 定义：define
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@(define def-eval (make-base-eval))

@title[#:tag "define"]{定义：@racket[define]}

基本定义具为如下形式：

@specform[(define id expr)]{}

在这种情况下，@racket[_id]绑定到了@racket[_expr]的结果。

@defexamples[
#:eval def-eval
(define salutation (list-ref '("Hi" "Hello") (random 2)))
salutation
]

@; ---------------------------------------------------------------------
@include-section["04.05.01.scrbl"]
@include-section["04.05.02.scrbl"]
@include-section["04.05.03.scrbl"]
@include-section["04.05.04.scrbl"]

@; ----------------------------------------------------------------------
@close-eval[def-eval]
