;07.06.scrbl
;7.6 用#:exists和#:∃抽象合约
#lang scribble/doc
@(require scribble/manual scribble/eval "utils.rkt"
          (for-label racket/contract))

@title[#:tag "contracts-exists"]{用@racket[#:exists]和@racket[#:∃]抽象合约}

合约系统提供了可以保护抽象的存在性合约，确保模块的客户机不能依赖于精确表达选择，以便你有利于你的数据结构。

@racket[contract-out]表允许你写作：@racketblock[#:∃ _name-of-a-new-contract]作为其从句之一。这个声明介绍变量@racket[_name-of-a-new-contract]，绑定到一个新的合约，隐藏关于它保护的值的信息。

作为一个例子，考虑这个（简单）一个队列数据结构的实现：

@racketmod[racket
           (define empty '())
           (define (enq top queue) (append queue (list top)))
           (define (next queue) (car queue))
           (define (deq queue) (cdr queue))
           (define (empty? queue) (null? queue))
           
           (provide
            (contract-out
             [empty (listof integer?)]
             [enq (-> integer? (listof integer?) (listof integer?))]
             [next (-> (listof integer?) integer?)]
             [deq (-> (listof integer?) (listof integer?))]
             [empty? (-> (listof integer?) boolean?)]))]

本代码实现了一个单纯的列表成员队列，这意味着数据结构的客户机可能对数据结构直接使用@racket[car]和@racket[cdr]（也许偶然地），从而在描述里的任何改变（用更有效的描述来说是支持分期常量时间入队和出队操作）可能会破坏客户机代码。

为确保队列的描述是抽象的，我们可以在@racket[contract-out]表达式里使用@racket[#:∃]，就像这样：

@racketblock[(provide
              (contract-out
               #:∃ queue
               [empty queue]
               [enq (-> integer? queue queue)]
               [next (-> queue integer?)]
               [deq (-> queue queue)]
               [empty? (-> queue boolean?)]))]

现在，如果数据结构的客户机尝试使用@racket[car]和@racket[cdr]，他们会收到一个错误，而不是去摆弄的队列的内部成员。

也可以参见《@ctc-link["exists-gotcha"]》（Exists Contracts and Predicates）。