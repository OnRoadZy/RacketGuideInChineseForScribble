;04.04.04.scrbl
;4.4.4 多解函数：case-lambda
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "case-lambda"]{多解函数：case-lambda}

@racket[case-lambda]表创建一个函数，该函数可以根据所提供的参数的数量具有完全不同的行为。一个case-lambda表达式有以下形式：

@specform/subs[
(case-lambda
  [formals body ...+]
  ...)
([formals (arg-id ...)
          rest-id
          (arg-id ...+ . rest-id)])
]

每个@racket[[_formals _body ...+]]类似于@racket[(lambda
_formals _body ...+)]。通过@racket[case-lambda]应用函数生成类似于应用一个@racket[lambda]匹配给定参数数量的第一种情况。

@defexamples[
(define greet
  (case-lambda
    [(name) (string-append "Hello, " name)]
    [(given surname) (string-append "Hello, " given " " surname)]))

(greet "John")
(greet "John" "Smith")
(greet)
]

@racket[case-lambda]函数不能直接支持可选参数或关键字参数。