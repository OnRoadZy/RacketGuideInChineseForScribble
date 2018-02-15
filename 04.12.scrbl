;04.12.scrbl
;4.12 简单分派：case
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "case"]{简单分派：@racket[case]}

通过将表达式的结果与子句的值相匹配，@racket[case]表分派一个子句：

@specform[(case expr
            [(datum ...+) body ...+]
            ...)]

每个@racket[_datum]将使用@racket[equal?]对比@racket[_expr]的结果，然后相应的@racket[body]被求值。@racket[case]表可以为@math{N}个@racket[datum]在@math{O(log N)}时间内分派正确的从句。

可以给每个从句提供多个@racket[_datum]，而且如果任何一个@racket[_datum]匹配，那么相应的@racket[_body]被求值。

@examples[
(let ([v (random 6)])
  (printf "~a\n" v)
  (case v
    [(0) 'zero]
    [(1) 'one]
    [(2) 'two]
    [(3 4 5) 'many]))
]

一个@racket[case]表最后一个从句可以使用@racket[else]，就像@racket[cond]那样：

@examples[
(case (random 6)
  [(0) 'zero]
  [(1) 'one]
  [(2) 'two]
  [else 'many])
]

对于更一般的模式匹配（但没有分派时间保证），使用@racket[match]，这个会在《模式匹配》（@secref["match"]）中介绍。