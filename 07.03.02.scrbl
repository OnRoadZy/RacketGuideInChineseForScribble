;07.03.02.scrbl
;7.3.2 剩余参数
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "utils.rkt"
          (for-label framework/framework
                     racket/contract
                     racket/gui))

@title[#:tag "rest-args-argument"]{剩余参数}

@racket[max]操作符至少接受一个实数，但它接受任意数量的附加参数。您可以使用@tech{剩余参数（rest argument）}编写其它此类函数，例如在@racket[max-abs]中：

@racketblock[
(define (max-abs n . rst)
  (foldr (lambda (n m) (max (abs n) m)) (abs n) rst))
]

通过一个合同描述此函数需要进一步扩展@racket[->*]：一个@racket[#:rest]关键字在必需参数和可选参数之后指定一个参数列表合约：

@racketblock[
(provide
 (contract-out
  [max-abs (->* (real?) () #:rest (listof real?) real?)]))
]

正如对@racket[->*]的通常情况，必需参数合约被封闭在第一对括号中，在这种情况下是一个实数。空括号表示没有可选参数（不包括剩余参数）。剩余参数合约如下@racket[#:rest]；因为所有的额外的参数必须是实数，剩余参数列表必须满足合约@racket[(listof real?)]。