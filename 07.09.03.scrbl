;07.09.03.scrbl
;7.9.3 合约的生存期和判定
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          racket/sandbox
          "utils.rkt"
          (for-label racket/base
                     racket/contract))

@title[#:tag "exists-gotcha"]{合约的生存期和判定}

很像上面的@racket[eq?]例子，@racket[#:∃]合约可以改变一个程序的行为。

具体来说，对@racket[#:∃]合约的@racket[null?]判断（和许多其它判断）返回@racket[#f]，并改变其中一个合同的@racket[any/c]意味着@racket[null?]现在可能反而返回@racket[#t]，导致在任意不同的行为上依赖于这个布尔值，这可能在程序持续影响。

@defmodulelang[racket/exists]

解决上述问题，@racketmodname[racket/exists]库行为就像@racketmodname[racket]，但当提供@racket[#:∃]合约时判断会发出错误信号。

经验：不要使用判断@racket[#:∃]合约，但是如果你并不确定，用@racketmodname[racket/exists]在是安全的。