;07.02.scrbl
;7.2 函数的简单合约
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/core
          racket/list
          scribble/racket
          "guide-utils.rkt"
          "utils.rkt"
          (for-label racket/contract))

@title[#:tag "contract-func"]{函数的简单合约}

一个数学函数有一个@deftech{定义域(domain)}和一个@deftech{值域(range)}。定义域表示函数可以作为参数接受的值类型，值域表示它生成的值类型。描述函数及其定义域和值域的惯常的符号是

@racketblock[
f : A -> B
]

其中@racket[A]是函数的定义域，@racket[B]是值域。

编程语言中的函数也有定义域和值域，而合约可以确保函数只接收定义域中的值，只在其值域内生成值。一个@racket[->]为函数创建一个这样的合约。一个@racket[->]之后的表指定定义域的合约，最后指定值域的合约。

这里有一个模块，可以代表一个银行帐户：

@racketmod[
racket

(provide (contract-out
          [deposit (-> number? any)]
          [balance (-> number?)]))

(define amount 0)
(define (deposit a) (set! amount (+ amount a)))
(define (balance) amount)
]

这个模块导出两个函数：

@itemize[

@item{@racket[deposit]，接受一个数字并返回某个未在合约中指定的值，}

@item{@racket[balance]，返回一个指示账户当前余额的数字。}

]

当一个模块导出一个函数时，它在两个通道之间建立一个“服务器”（server）并导入该函数的“客户机”（client）模块之间的通信通道。如果客户机模块调用该函数，它将向服务器模块发送一个值。相反，如果这样的函数调用结束，函数返回一个值，服务器模块就会将一个值发送回客户机模块。这种区分客户机-服务器的区别是很重要的，因为当出现问题时，一方或另一方应受到责备。

如果客户机模块向@racket['millions]申请存款（@racket[deposit]），这将违反合约。合约监督系统会抓住这一违规行为，并责怪客户与上面的模块违反合同。与此相反，如果@racket[balance]函数返回@racket['broke]，合同监控系统将归咎于服务器模块。

一个@racket[->]本身不是合约；它是一种合约组合（@deftech{contract combinator}），它结合其它合约构成合约。

@;-------------------------------------------------------------------------
@include-section["07.02.01.scrbl"]
@include-section["07.02.02.scrbl"]
@include-section["07.02.03.scrbl"]
@include-section["07.02.04.scrbl"]
@include-section["07.02.05.scrbl"]
@include-section["07.02.06.scrbl"]
@include-section["07.02.07.scrbl"]