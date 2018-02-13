;07.05.scrbl
;7.5 结构的合约
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt"
          "utils.rkt"
          (for-label racket/contract))

@title[#:tag "contracts-struct"]{结构的合约}

模块以两种方式处理结构。首先它们导出@racket[struct]的定义，即创造一种明确方法的结构的能力，存取它们的字段，修改它们，并使这类结构和领域内的每一种值有区别。其次，有时模块导出特定的结构，并希望它的字段包含某种类型的值。本节说明如何使用合约保护结构。

@include-section["07.05.01.scrbl"]
@include-section["07.05.02.scrbl"]
@include-section["07.05.03.scrbl"]