;07.03.scrbl
;7.3 通常的函数合约
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "utils.rkt"
          (for-label framework/framework
                     racket/contract
                     racket/gui))

@title[#:tag "contracts-general-functions"]{通常的函数合约}

@racket[->]合约构造函数为固定数量参数的函数工作，并且结果合约与输入参数无关。为了支持函数的其它类型，Racket提供额外的合约构造函数，尤其是 @racket[->*]和@racket[->i]。

@;----------------------------------------------------------------------
@include-section["07.03.01.scrbl"]
@include-section["07.03.02.scrbl"]
@include-section["07.03.03.scrbl"]
@include-section["07.03.04.scrbl"]
@include-section["07.03.05.scrbl"]
@include-section["07.03.06.scrbl"]
@include-section["07.03.07.scrbl"]
@include-section["07.03.08.scrbl"]
@include-section["07.03.09.scrbl"]
