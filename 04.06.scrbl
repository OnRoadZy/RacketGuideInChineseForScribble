;04.06.scrbl
;4.6 局部绑定
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{局部绑定}

虽然内部@racket[define]可用于局部绑定，Racket提供了三种形式给予程序员在绑定方面的更多控制：@racket[let]、@racket[let*]和@racket[letrec]。

@include-section["04.06.01.scrbl"]
@include-section["04.06.02.scrbl"]
@include-section["04.06.03.scrbl"]
@include-section["04.06.04.scrbl"]
@include-section["04.06.05.scrbl"]