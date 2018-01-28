;04.06.04.scrbl
;4.6.4 命名let
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{命名let}

命名@racket[let]是一个迭代和递归表。它使用与局部绑定相同的语法关键字@racket[let]，但在@racket[let]之后的标识符（而不是一个括号）触发不同的解析。

@specform[
(let proc-id ([arg-id init-expr] ...)
  body ...+)
]

命名的@racket[let]表等效于

@racketblock[
(letrec ([_proc-id (lambda (_arg-id ...)
                     _body ...+)])
  (_proc-id _init-expr ...))
]
也就是说，一个命名的@racket[let]绑定一个只在函数体中可见的函数标识符，并且用一些初始表达式的值隐式调用函数。

@defexamples[
(define (duplicate pos lst)
  (let dup ([i 0]
            [lst lst])
   (cond
    [(= i pos) (cons (car lst) lst)]
    [else (cons (car lst) (dup (+ i 1) (cdr lst)))])))
(duplicate 1 (list "apple" "cheese burger!" "banana"))
]
