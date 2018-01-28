;04.04.scrbl
;4.4 lambda函数（程序）
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{lambda函数（程序）}

@racket[lambda]表达式创建函数。在最简单的情况，@racket[lambda]表达式具有的形式：

@specform[
(lambda (arg-id ...)
  body ...+)
]

具有@math{n}个@racket[_arg-id]的@racket[lambda]表接受@math{n}个参数：

@interaction[
((lambda (x) x)
 1)
((lambda (x y) (+ x y))
 1 2)
((lambda (x y) (+ x y))
 1)
]