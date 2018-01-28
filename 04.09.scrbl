;04.09.scrbl
;4.9 赋值：set!
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "set!"]{赋值：@racket[set!]}

使用@racket[set!]赋值给变量：

@specform[(set! id expr)]

一个@racket[set!]表达式对@racket[_expr]求值并改变@racket[_id]（它必须限制在闭括号的环境内）为结果值。@racket[set!]表达式自己返回的结果是@|void-const|。

@defexamples[
(define greeted null)
(define (greet name)
  (set! greeted (cons name greeted))
  (string-append "Hello, " name))

(greet "Athos")
(greet "Porthos")
(greet "Aramis")
greeted
]

@defs+int[
[(define (make-running-total)
   (let ([n 0])
     (lambda ()
       (set! n (+ n 1))
       n)))
 (define win (make-running-total))
 (define lose (make-running-total))]
(win)
(win)
(lose)
(win)
]

@;-----------------------------------------------
@include-section["04.09.01.scrbl"]
@include-section["04.09.02.scrbl"]