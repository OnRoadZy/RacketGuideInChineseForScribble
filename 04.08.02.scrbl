;04.08.02.scrbl
;4.8.2 后置影响：begin0
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "effects-after-begin0"]{后置影响：@racket[begin0]}

一个@racket[begin0]表达式与有一个@racket[begin]表达式有相同的语法：

@specform[(begin0 expr ...+)]{}

不同的是@racket[begin0]返回第一个@racket[expr]的结果，而不是最后一个@racket[expr]的结果。@racket[begin0]表对于实现发生在一个计算之后的副作用是有用的，尤其是在计算产生了一个未知的数值结果的情况下。

@defexamples[
(define (log-times thunk)
  (printf "Start: ~s\n" (current-inexact-milliseconds))
  (begin0
    (thunk)
    (printf "End..: ~s\n" (current-inexact-milliseconds))))
(log-times (lambda () (sleep 0.1) 0))
(log-times (lambda () (values 1 2)))
]