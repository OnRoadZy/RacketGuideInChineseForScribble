;07.01.scrbl
;7.1 合约和边界
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "utils.rkt"
          (for-label racket/base
                     racket/contract))

@title[#:tag "contract-boundaries"]{合约和边界}

如同两个商业伙伴之间的合同，软件合约是双方之间的协议。协议规定了从一方传给另一方的每一产品（或价值）的义务和保证。

因此，合约确定了双方之间的边界。当值跨越边界时，合约监督系统执行合约检查，确保合作伙伴遵守既定合约。

在这种精神下，Racket支持合约主要在模块边界。具体来说，程序员可以附加合约来@racket[提供（provide）]从句，从而对导出值的使用施加约束和承诺。例如，导出说明

@racketmod[
racket

(provide (contract-out [amount positive?]))

(define amount ...)
]

承诺上述模块的所有客户，@racket[amount]值将始终是正数。合约系统仔细地监测了该模块的义务。每次客户提到@racket[amount]时，监视器都会检查@racket[amount]值是否确实是正数。

合约库是建立在Racket语言中内部的，但是如果你想使用@racket[racket/base]，你可以像这样明确地导入合约库：

@racketmod[
racket/base
(require racket/contract) (code:comment "now we can write contracts")

(provide (contract-out [amount positive?]))

(define amount ...)
]

@;-----------------------------------------------------
@include-section["07.01.01.scrbl"]