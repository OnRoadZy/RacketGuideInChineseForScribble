;04.05.02.scrbl
;4.5.2 咖喱函数简写
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@(define def-eval (make-base-eval))

@title[#:tag "curried-function-shorthand"]{咖喱函数简写}

注意下面的@racket[make-add-suffix]函数接收一个字符串并返回另一个带字符串的函数：

@def+int[
#:eval def-eval
(define make-add-suffix
  (lambda (s2)
    (lambda (s) (string-append s s2))))
]

虽然不常见，但@racket[make-add-suffix]的结果可以直接调用，就像这样：

@interaction[
#:eval def-eval
((make-add-suffix "!") "hello")
]

从某种意义上说，@racket[make-add-suffix]是一个函数，需要两个参数，但每次只需要一个参数。一个函数带有一些参数并返回一个函数会提供更多，有时被称为一个@defterm{咖喱函数（curried function）}。

使用@racket[define]的函数简写形式，@racket[make-add-suffix]可以等效地写成：

@racketblock[
(define (make-add-suffix s2)
  (lambda (s) (string-append s s2)))
]

这个简写反映了@racket[(make-add-suffix "!")]函数调用的形态。@racket[define]表更进一步支持定义反映嵌套函数调用的咖喱函数简写：

@def+int[
#:eval def-eval
(define ((make-add-suffix s2) s)
  (string-append s s2))
((make-add-suffix "!") "hello")
]
@defs+int[
#:eval def-eval
[(define louder (make-add-suffix "!"))
 (define less-sure (make-add-suffix "?"))]
(less-sure "really")
(louder "really")
]

@racket[define]函数简写的完整语法如下所示：

@specform/subs[(define (head args) body ...+)
               ([head id
                      (head args)]
                [args (code:line arg ...)
                      (code:line arg ... @#,racketparenfont{.} rest-id)])]{}

这个简写的扩展有一个给定义中的每个@racket[_head]的嵌套@racket[lambda]表，最里面的@racket[_head]与最外面的@racket[lambda]通信。