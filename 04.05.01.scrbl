;04.05.01.scrbl
;4.5.1 函数简写
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@(define def-eval (make-base-eval))

@title{函数简写}

@racket[定义（define）]表还支持函数定义的简写：

@specform[(define (id arg ...) body ...+)]{}

这是以下内容的简写：

@racketblock[
(define _id (lambda (_arg ...) _body ...+))
]

@defexamples[
#:eval def-eval
(define (greet name)
  (string-append salutation ", " name))
(greet "John")
]

@def+int[
#:eval def-eval
(define (greet first [surname "Smith"] #:hi [hi salutation])
  (string-append hi ", " first " " surname))
(greet "John")
(greet "John" #:hi "Hey")
(greet "John" "Doe")
]

通过@racket[define]这个函数简写也支持一个@tech{剩余参数(rest argument)}（即，一个额外参数用于在列表中收集最后参数）：

@specform[(define (id arg ... . rest-id) body ...+)]{}

这是以下内容的简写：

@racketblock[
(define _id (lambda (_arg ... . _rest-id) _body ...+))
]

@defexamples[
#:eval def-eval
(define (avg . l)
  (/ (apply + l) (length l)))
(avg 1 2 3)
]