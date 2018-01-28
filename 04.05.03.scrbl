;04.05.03.scrbl
;4.5.3 多值和define-values
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@(define def-eval (make-base-eval))

@title{多值和define-values}

Racket表达式通常产生一个单独的结果，但有些表达式可以产生多个结果。例如，@racket[quotient]（商）和@racket[remainder]（余数）各自产生一个值，但@racket[quotient/remainder]同时产生相同的两个值：

@interaction[
#:eval def-eval
(quotient 13 3)
(remainder 13 3)
(quotient/remainder 13 3)
]

如上所示，@tech{REPL}在自己的行打印每一结果值。

多值函数可以用@racket[values]函数来实现，它接受任意数量的值，并将它们作为结果返回：

@interaction[
#:eval def-eval
(values 1 2 3)
]
@def+int[
#:eval def-eval
(define (split-name name)
  (let ([parts (regexp-split " " name)])
    (if (= (length parts) 2)
        (values (list-ref parts 0) (list-ref parts 1))
        (error "not a <first> <last> name"))))
(split-name "Adam Smith")
]

@racket[define-values]表同时将多个标识符绑定到多个结果产生单个表达式：

@specform[(define-values (id ...) expr)]{}

由@racket[_expr]产生的结果数必须与@racket[_id]的数值相匹配。

@defexamples[
#:eval def-eval
(define-values (given surname) (split-name "Adam Smith"))
given
surname
]

一个 @racket[define]表（不是一个函数简写）等价于一个带有单个@racket[_id]的@racket[define-values]表。