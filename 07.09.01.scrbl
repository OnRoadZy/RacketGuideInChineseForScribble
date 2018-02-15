;07.09.01.scrbl
;7.9.1 合约和eq?
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          racket/sandbox
          "utils.rkt"
          (for-label racket/base
                     racket/contract))

@title[#:tag "contracts-and-eq"]{合约和@racket[eq?]}

一般来说，在程序中添加一个合约既应该使程序的行为保持不变，也应该表明违反合约的行为。这几乎是真正的Racket合约，只有一个例外：@racket[eq?]。

@racket[eq?]程序的设计是快速的，并且没有提供太多的确保方式，除非它返回true，这意味着这两个值在所有方面都是相同的。在内部，这是作为一个低级的指针相等实现的，因此它公开了如何实现Racket的信息（以及如何实现合约）。

用@racket[eq?]合约交互是糟糕的，因为函数合约检查是在内部作为包装函数实现的。例如，考虑这个模块：

@racketmod[
racket

(define (make-adder x)
  (if (= 1 x)
      add1
      (lambda (y) (+ x y))))
(provide (contract-out 
          [make-adder (-> number? (-> number? number?))]))
]

它的导出@racket[make-adder]函数，它是通常咖喱附加函数，除了当它的输入是@racket[1]时，它返回Racket的@racket[add1]。

你可能希望这样：

@racketblock[
(eq? (make-adder 1)
     (make-adder 1))
]

应该返回@racket[#t]，但却没有。如果合约被改成了@racket[any/c]（或者甚至是@racket[(-> number? any/c)]），那么@racket[eq?]调用将返回@racket[#t]。

经验：不要对有合约的值使用@racket[eq?]。