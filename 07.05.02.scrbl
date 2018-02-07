;07.05.02.scrbl
;7.5.2 对所有值的确保
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt"
          "utils.rkt"
          (for-label racket/contract))

@title[#:tag "define-struct"]{对所有值的确保}

这《如何设计程序》（ @|HtDP|）本书教授了@racket[posn]应该只包含在它们两个字段里的数值。有了合约，我们将执行以下非正式数据定义：

@racketmod[
racket
(struct posn (x y))
  
(provide (contract-out
          [struct posn ((x number?) (y number?))]
          [p-okay posn?]
          [p-sick posn?]))

(define p-okay (posn 10 20))
(define p-sick (posn 'a 'b))
]

这个模块导出整个结构的定义：@racket[posn]、@racket[posn?]、@racket[posn-x]、@racket[posn-y]、@racket[set-posn-x!]和@racket[set-posn-y!]。 每个函数强制执行或承诺@racket[posn]结构的这两个字段是数值——当这些值在模块范围内传递时。因此，如果一个客户机对@racket[10]和@racket['a]调用@racket[posn]，合约系统就发出违反合约的信号。

然而，@racket[posn]模块内的@racket[p-sick]的创建，并不违反合约。@racket[posn]函数是在内部使用，所以@racket['a]和@racket['b]不跨约模块范围。同样，当@racket[p-sick]跨越@racket[posn]的范围时，合约承诺了@racket[posn?]，别的什么也没有。特别是，@racket[p-sick]的字段数是数值这个检查完全不需要。

对模块范围的合约检查意味着@racket[p-okay]和@racket[p-sick]从客户机的角度看起来相似，直到客户机引用以下片断：

@racketmod[
racket
(require lang/posn)
  
... (posn-x p-sick) ...
]

使用@racket[posn-x]是客户机可以找到一个@racket[posn]包含@racket[x]字段的唯一途径。对@racket[posn-x]应用程序发送@racket[p-sick]回传给@racket[posn]模块并且结果值——@racket['a]这里——回传给客户机，再跨越模块范围。在这一点上，合约系统发现承诺被打破了。具体来说，@racket[posn-x]没有返回一个数值但却返回了一个符号，因此应归咎于它。

这个具体的例子表明，对违背合约的解释并不总是指明错误的来源。好消息是，错误位于@racket[posn]模块。坏消息是这种解释是误导性的。虽然这是真的，@racket[posn-x]产生一个符号而不是一个数值，它是程序员的责任，他从符号创建了@racket[posn]，即程序员添加了以下内容

@racketblock[
(define p-sick (posn 'a 'b))
]

到模块中。所以，当你在寻找基于违反合同的bug时，记住这个例子。

如果我们想修复@racket[p-sick]的合约这样的错误，它是当@racket[sick]被导出时被引发的，一个单独的改变就足够了：

@racketblock[
(provide
 (contract-out
  ...
  [p-sick (struct/c posn number? number?)]))
]

更确切地说，代替作为一个普通的@racket[posn?]导出@racket[p-sick]的方式，我们使用@racket[struct/c]合约对组件进行强制约束。