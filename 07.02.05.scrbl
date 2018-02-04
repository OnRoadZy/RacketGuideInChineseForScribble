;07.02.05.scrbl
;7.2.5 合约的高阶函数
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/core
          racket/list
          scribble/racket
          "guide-utils.rkt"
          "utils.rkt"
          (for-label racket/contract))

@title{合约的高阶函数}

函数合约不仅仅局限于域或范围上的简单断言。在这里论述的任何合约组合，包括函数合约本身，可作为一个函数的参数和结果的合约。

例如：

@racketblock[(-> integer? (-> integer? integer?))]
 
是一份合约，描述了一个咖喱函数。它匹配接受一个参数的函数，并且接着在返回一个整数之前返回另一个接受第二个参数的函数。如果服务器使用这个合约导出一个函数@racket[make-adder]，如果@racket[make-adder]返回一个非函数的值，那么应归咎于服务器。如果@racket[make-adder]确实返回一个函数，但得到的函数应用于一个非整数的值，则应归咎于客户机。

同样，合约

@racketblock[(-> (-> integer? integer?) integer?)]

描述接受其它函数作为输入的函数。如果一个服务器用它的合约导出一个函数@racket[twice]，那么@racket[twice]应用给一个值而不是一个带一个参数的函数，那么归咎于客户机。如果@racket[twice]应用给一个带一个参数的函数，并且@racket[twice]调用这个给定的函数作为值而不是一个整数，那么归咎于服务器。 