;07.02.03.scrbl
;7.2.3 and和any/c
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/core
          racket/list
          scribble/racket
          "guide-utils.rkt"
          "utils.rkt"
          (for-label racket/contract))

@title[#:tag "any-and-anyc"]{7.2.3 and和any/c}

用于@racket[deposit]的@racket[any]合约符合任何结果，只能在函数合约的范围内使用。代替上面的@racket[any]，我们可以使用更具体的合约@racket[void?]，它表示函数总是返回@racket[(void)]值。然而，@racket[void?]合约要求合约监控系统每次调用函数时都要检查返回值，即使“客户机”模块不能很好地处理这个值。相反，@racket[any]告诉监控系统不检查返回值，它告诉潜在客户机，“服务器”模块对函数的返回值不作任何承诺，甚至不管它是单个值或多个值。

@racket[any/c]合约和@racket[any]类似，因为它对值没有任何要求。与@racket[any]不同的是，@racket[any/c]表示一个单个值，它适合用作参数合约。使用@racket[any/c]作为值域合约，强迫对函数产生的一个单个值进行检查。就像这样，

@racketblock[(-> integer? any)]

描述一个函数，该函数接受一个整数并返回任意数量的值，然而

@racketblock[(-> integer? any/c)]

描述接受整数并生成单个结果的函数（但对结果没有更多说明）。以下函数

@racketblock[
(define (f x) (values (+ x 1) (- x 1)))
]

匹配@racket[(-> integer? any)]，但不匹配@racket[(-> integer? any/c)]。

当从一个函数获得一个单个结果的承诺特别重要时，使用@racket[any/c]作为结果的合约。当希望尽可能少地承诺（并尽可能少地检查）函数的结果时，使用@racket[any/c]合约。