;07.02.02.scrbl
;7.2.2 define/contract和->的使用
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/core
          racket/list
          scribble/racket
          "guide-utils.rkt"
          "utils.rkt"
          (for-label racket/contract))

@title[#:tag "simple-nested"]{ @racket[define/contract]和 @racket[->]的使用}

在《嵌套的合约边界测试》（@ctc-link["intro-nested"]）中引入的@racket[define/contract]表也可以用来定义合约中的函数。例如,

@racketblock[
(define/contract (deposit amount)
  (-> number? any)
  (code:comment "implementation goes here")
  ....)
]

它用合约更早定义@racket[deposit]函数。请注意，这对@racket[deposit]的使用有两个潜在的重要影响：

@itemlist[#:style 'ordered
  @item{由于合约总是在调用@racket[deposit]时进行检查，即使在定义它的模块内，这也可能增加合约被检查的次数。这可能导致性能下降。如果函数在循环中反复调用或使用递归，尤其如此。}

@item{在某些情况下，当同一模块中的其它代码调用时，可以编写一个函数来接受更宽松的一组输入。对于此类用例，通过@racket[define/contract]建立的合同边界就过于严格。}

]