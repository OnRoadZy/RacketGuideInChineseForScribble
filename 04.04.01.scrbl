;04.04.01.scrbl
;4.4.1 申明剩余（rest）参数
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{申明剩余（rest）参数}

一个@racket[lambda]表达式也可以有这种形式：

@specform[
(lambda rest-id
  body ...+)
]

也就是说，@racket[lambda]表达式可以有一个没有被圆括号包围的单个@racket[_rest-id]。所得到的函数接受任意数目的参数，并且这个参数放入一个绑定到@racket[_rest-id]的列表：

@examples[
((lambda x x)
 1 2 3)
((lambda x x))
((lambda x (car x))
 1 2 3)
]

带有一个@racket[_rest-id]的函数经常使用@racket[apply]函数调用另一个函数，它接受任意数量的参数。

@defexamples[
(define max-mag
  (lambda nums
    (apply max (map magnitude nums))))

(max 1 -2 0)
(max-mag 1 -2 0)
]

@racket[lambda]表还支持必需参数与@racket[_rest-id]相结合：

@specform[
(lambda (arg-id ...+ . rest-id)
  body ...+)
]

这个表的结果是一个函数，它至少需要与@racket[_arg-id]一样多的参数，并且还接受任意数量的附加参数。

@defexamples[
(define max-mag
  (lambda (num . nums)
    (apply max (map magnitude (cons num nums)))))

(max-mag 1 -2 0)
(max-mag)
]

@racket[_rest-id]变量有时称为@deftech{rest参数（rest
argument）}，因为它接受函数参数的“rest”。