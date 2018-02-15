;07.01.02.scrbl
;7.1.2 合约与模块的测试
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "utils.rkt"
          (for-label racket/base
                     racket/contract))

@title[#:tag "experimenting-with-contracts-and-modules"]{合约与模块的测试}

在这一章中的所有合同和模块（不包括那些只是跟随）是使用标准的@tt{#lang}语法描述的模块。由于模块是合约中各方之间的边界，所以示例涉及多个模块。

测试与多个模块在一个单一的模块或DrRacket的@tech{定义范围（definitions area）}内，使用Racket的子模块。例如，测试一下本节前面的示例，如下所示：

@racketmod[
racket

(module+ server
  (provide (contract-out [amount (and/c number? positive?)]))
  (define amount 150))
 
(module+ main
  (require (submod ".." server))
  (+ amount 10))
]

每个模块及其合约都用前面的@racket[module+]关键字封装在圆括号中。 @racket[module]后面的第一个表是模块的名称，将在随后的@racket[require]语句中使用（其中每个引用都通过一个@racket[require]对名称用@racket[".."]进行前缀）。