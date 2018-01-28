;04.03.03.scrbl
;4.3.3 apply函数
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{apply函数}

函数调用的语法支持任意数量的参数，但是一个特定的调用总是指定一个固定数量的参数。因此，一个带参数列表的函数不能直接将一个类似于@racket[+]的函数应用到列表中的所有项中：

@def+int[
(define (avg lst) (code:comment @#,elem{不会运行...})
  (/ (+ lst) (length lst)))
(avg '(1 2 3))
]

@def+int[
(define (avg lst) (code:comment @#,elem{不会总是运行...})
  (/ (+ (list-ref lst 0) (list-ref lst 1) (list-ref lst 2))
     (length lst)))
(avg '(1 2 3))
(avg '(1 2))
]

@racket[apply]函数提供了一种绕过这种限制的方法。它使用一个函数和一个@italic{list}参数，并将函数应用到列表中的值：

@def+int[
(define (avg lst)
  (/ (apply + lst) (length lst)))
(avg '(1 2 3))
(avg '(1 2))
(avg '(1 2 3 4))
]

为方便起见，@racket[apply]函数接受函数和列表之间的附加参数。额外的参数被有效地加入参数列表：

@def+int[
(define (anti-sum lst)
  (apply - 0 lst))
(anti-sum '(1 2 3))
]

@racket[apply]函数也接受关键字参数，并将其传递给调用函数：

@racketblock[
(apply go #:mode 'fast '("super.rkt"))
(apply go '("super.rkt") #:mode 'fast)
]

包含在@racket[apply]的列表参数中的关键字不算作调用函数的关键字参数；相反，这个列表中的所有参数都被位置参数处理。要将一个关键字参数列表传递给函数，使用@racket[keyword-apply]函数，它接受一个要应用的函数和三个列表。前两个列表是平行的，其中第一个列表包含关键字（按@racket[keyword<?]排序），第二个列表包含每个关键字的对应参数。第三个列表包含位置函数参数，就像@racket[apply]。

@racketblock[
(keyword-apply go
               '(#:mode)
               '(fast)
               '("super.rkt"))
]