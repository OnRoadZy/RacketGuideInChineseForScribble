;04.09.02.scrbl
;4.9.2 多值赋值：set!-values
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "multiple-values-set!-values"]{多值赋值：@racket[set!-values]}

@racket[set!-values]表一次赋值给多个变量，给出一个生成适当的数值的表达式：
 
@specform[(set!-values (id ...) expr)]

这个表等价于使用@racket[let-values]从@racket[_expr]接收多个结果，然后将结果使用@racket[set!]单独赋值给@racket[_id]。

@defexamples[
(define game
  (let ([w 0]
        [l 0])
    (lambda (win?)
      (if win?
          (set! w (+ w 1))
          (set! l (+ l 1)))
      (begin0
        (values w l)
        (code:comment @#,t{swap sides...})
        (set!-values (w l) (values l w))))))
(game #t)
(game #t)
(game #f)]
