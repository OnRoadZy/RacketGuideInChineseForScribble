;04.03.01.scrbl
;4.3.1 求值顺序和元数
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag: "evaluation-order-and-arity"]{求值顺序和元数}

一个函数调用求值是首先求值@racket[_proc-expr]和为所有@racket[_arg-expr]（由左至右）。然后，如果@racket[_arg-expr]产生一个函数接受@racket[_arg-expr]提供的所有参数，这个函数被调用。否则，将引发异常。

@examples[
(cons 1 null)
(+ 1 2 3)
(cons 1 2 3)
(1 2 3)
]

某些函数，如@racket[cons]，接受固定数量的参数。某些函数，如@racket[+]或@racket[list]，接受任意数量的参数。一些函数接受一系列参数计数；例如@racket[substring]接受两个或三个参数。一个函数的元数@idefterm{arity}是它接受参数的数量。