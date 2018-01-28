;04.06.02.scrbl
;4.6.2 相继绑定：let*
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{相继绑定：let*}

@racket[let*]的语法和@racket[let]的一样：

@specform[(let* ([id expr] ...) body ...+)]{}

不同的是，每个@racket[_id]可用于以后的@racket[_expr]，以及@racket[_body]内。此外，@racket[_id]不需要有区别，最新的绑定可见。

@examples[
(let* ([x (list "Burroughs")]
       [y (cons "Rice" x)]
       [z (cons "Edgar" y)])
  (list x y z))
(let* ([name (list "Burroughs")]
       [name (cons "Rice" name)]
       [name (cons "Edgar" name)])
  name)
]

换言之， @racket[let*]表是相当于嵌套的@racket[let]表，每一个都有一个单独的绑定：

@interaction[
(let ([name (list "Burroughs")])
  (let ([name (cons "Rice" name)])
    (let ([name (cons "Edgar" name)])
      name)))
]