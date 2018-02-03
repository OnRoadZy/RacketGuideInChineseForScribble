;07.01.01.scrbl
;7.1.1 合约的违反
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "utils.rkt"
          (for-label racket/base
                     racket/contract))

@title[#:tag "amount0"]{合约的违反}

如果我们将@racket[amount]绑定到一个非正的数字，

@racketmod[
racket

(provide (contract-out [amount positive?]))

(define amount 0)]

然后，当需要模块时，监控系统发出违反合同的信号，并指责模块违反了承诺。

更大的错误是将@racket[amount]绑定到非数值上：

@racketmod[
racket

(provide (contract-out [amount positive?]))

(define amount 'amount)
]

在这种情况下，监测系统将对一个符号使用@racket[positive?]，但@racket[positive?]报告错误，因为它的定义域是数字。为了使合约掌握我们对所有Racket值的意图，我们可以确保这两个合约的值是一个数字并且是正值，把这两个合约与@racket[and/c]结合起来：

@racketblock[
(provide (contract-out [amount (and/c number? positive?)]))
]