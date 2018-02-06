;07.03.05.scrbl
;7.3.5 case-lambda合约
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "utils.rkt"
          (for-label framework/framework
                     racket/contract
                     racket/gui))

@title[#:tag "case-lambda"]{case-lambda合约}

用@racket[case-lambda]定义的函数可能对其参数施加不同的约束，这取决于其提供了多少。例如，@racket[report-cost]函数可以将一对数字或字符串转换为一个新字符串：

@def+int[
(define report-cost
  (case-lambda
    [(lo hi) (format "between $~a and $~a" lo hi)]
    [(desc) (format "~a of dollars" desc)]))
(report-cost 5 8)
(report-cost "millions")
]

合约对这样的函数用@racket[case->]构成组合，这种结合对多个函数合约是必要的：

@racketblock[
(provide (contract-out
          [report-cost
           (case->
            (integer? integer? . -> . string?)
            (string? . -> . string?))]))
]

如你所见，@racket[report-cost]合约合并了两个函数合约，这与解释其函数所需的子句一样多。