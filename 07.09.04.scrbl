;07.09.04.scrbl
;7.9.4 定义递归合约
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          racket/sandbox
          "utils.rkt"
          (for-label racket/base
                     racket/contract))

@title{定义递归合约}

定义自参考合约时，很自然地去使用@racket[define]。例如，人们可能试图在这样的流上写一份合约：

@(define e (make-base-eval))
@(interaction-eval #:eval e (require racket/contract))
@interaction[
  #:eval e
(define stream/c
  (promise/c
   (or/c null?
         (cons/c number? stream/c))))
]
@close-eval[e]

不幸的是，这不起作用，因为在定义之前需要@racket[stream/c]的值。换句话说，所有的组合都渴望对它们的参数求值，即使它们不接受这些值。

相反，使用

@racketblock[
(define stream/c
  (promise/c
   (or/c
    null?
    (cons/c number? (recursive-contract stream/c)))))
]

@racket[recursive-contract]的使用延迟对标识符@racket[stream/c]的求值，直到第一次检查完合约之后，足够长的时间才能确保@racket[stream/c]被定义。

请参阅《@ctc-link["lazy-contracts"]》（Checking Properties of Data Structures）。