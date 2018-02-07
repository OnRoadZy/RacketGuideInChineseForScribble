;07.02.07.scrbl
;7.2.7 解析合约的错误消息
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/core
          racket/list
          scribble/racket
          "guide-utils.rkt"
          "utils.rkt"
          (for-label racket/contract))

@title[#:tag "dissecting-contract-errors"]{解析合约的错误消息}

@(define str "huh?")

@(begin
   (set! str
         (with-handlers ((exn:fail? exn-message))
           (contract-eval '(deposit -10))))
   "")

@(define (lines a b)
   (define lines (regexp-split #rx"\n" str))
   (table (style #f '())
          (map (λ (x) (list (paragraph error-color x)))
               (take (drop lines a) b))))

一般来说，每个合约的错误信息由六部分组成：

@itemize[
 @item{与合同有关的函数或方法的名称。而且“合同违约”或“违约”一词取决于合同是否违反了客户或在前一个示例中：@lines[0 1]}

 @item{2、对违反合约的准确的哪一方面的描述，@lines[1 2]}

 @item{完整的合约加上一个方向指明哪个方面被违反，@lines[3 2]}

 @item{合约表达的模块（或者更广泛地说，是合同所规定的边界），@lines[5 1]}

 @item{应归咎于哪个，@lines[6 2]}

 @item{以及合约出现的源程序定位。 @lines[8 1]}]