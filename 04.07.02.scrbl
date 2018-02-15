;04.07.02.scrbl
;4.7.2 组合测试：and和or
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "and+or"]{组合测试：@racket[and]和@racket[or]}

Racket的@racket[and]和@racket[or]是语法表，而不是函数。不像一个函数，如果前边的一个求值确定了答案，@racket[and]和@racket[or]表会忽略后边的表达式求值。

@specform[(and expr ...)]

如果其所有的@racket[_expr]产生@racket[#f]，@racket[and]表产生@racket[#f]。否则，它从它的 @racket[expr]第一个非@racket[#f]值产生结果值。作为一个特殊的情况，@racket[(or)]产生@racket[#f]。

@examples[
(code:line
 (define (got-milk? lst)
   (and (not (null? lst))
        (or (eq? 'milk (car lst))
            (got-milk? (cdr lst))))) (code:comment @#,t{recurs only if needed}))
(got-milk? '(apple banana))
(got-milk? '(apple milk banana))
]

如果求值达到@racket[and]或@racket[or]}表的最后一个@racket[_expr]，那么@racket[_expr]的值直接决定@racket[and]或@racket[or]}的结果。因此，最后一个@racket[_expr]是在尾部的位置，这意味着上面@racket[got-milk?]函数在固定空间中运行。