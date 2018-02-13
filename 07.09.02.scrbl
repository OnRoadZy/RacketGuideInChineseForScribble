;07.09.02.scrbl
;7.9.2 合约的范围和define/contract
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          racket/sandbox
          "utils.rkt"
          (for-label racket/base
                     racket/contract))

@title[#:tag "gotcha-nested"]{合约的范围和@racket[define/contract]}

合约的范围是被@racket[define/contract]所确定，它创建了一个嵌套的合约范围，有时不直观。当具有合约的多个函数或其它值相互作用时，情况尤其如此。例如，考虑这两个相互作用的函数：

@(define e2 (make-base-eval))
@(interaction-eval #:eval e2 (require racket/contract))
@interaction[#:eval e2
(define/contract (f x)
  (-> integer? integer?)
  x)
(define/contract (g)
  (-> string?)
  (f "not an integer"))
(g)
]

人们可能会认为，@racket[g]可能被归咎于破坏与@racket[f]的合约条件。然而，它们不是。相反，@racket[f]和@racket[g]之间的访问是通过封闭模块的顶层进行的。

更确切地说，@racket[f]和模块的顶层有@racket[(-> integer? integer?)]合约协调它们的相互作用，@racket[g]和顶层有@racket[(-> string?)]协调它们之间的相互作用，但是@racket[f]和@racket[g]之间没有直接的合约，这意味着@racket[g]主体中的@racket[f]的引用实际上是模块的顶层的职责，而不是@racket[g]的。换句话说，函数@racket[f]被赋予@racket[g]，@racket[g]与顶层之间没有约定，因此顶层应被归咎。

如果我们想增加@racket[g]和顶层之间的合约，我们可以使用@racket[define/contract]的@racket[#:freevar]申明并看到预期的归咎：

@interaction[#:eval e2
(define/contract (f x)
  (-> integer? integer?)
  x)
(define/contract (g)
  (-> string?)
  #:freevar f (-> integer? integer?)
  (f "not an integer"))
(g)
]
@(close-eval e2)

经验：如果两个值与合约应相互作用，把它们放在与模块范围内的合约不同的模块中或使用@racket[#:freevar]。