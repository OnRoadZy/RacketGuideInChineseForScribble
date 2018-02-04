;07.02.06.scrbl
;7.2.6 带”???“的合约信息
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/core
          racket/list
          scribble/racket
          "guide-utils.rkt"
          "utils.rkt"
          (for-label racket/contract))

@ctc-section[#:tag "flat-named-contracts"]{带”???“的合约信息}

你写了你的模块。你增加了合约。你将它们放入接口，以便客户机程序员拥有来自接口的所有信息。这是一门艺术：

@interaction[#:eval 
             contract-eval
             (module bank-server racket
               (provide
                (contract-out
                 [deposit (-> (λ (x)
                                (and (number? x) (integer? x) (>= x 0)))
                              any)]))
               
               (define total 0)
               (define (deposit a) (set! total (+ a total))))]

几个客户机使用了您的模块。其他人转而使用了他们的模块。突然他们中的一个看到了这个错误消息：

@interaction[#:eval 
             contract-eval
             (require 'bank-server)
             (deposit -10)]

@racketerror{???}在那里代表什么？如果我们有这样一个数据类型的名字，就像我们有字符串、数字等等，那不是很好吗？

在这种情况下，Racket提供了@deftech{扁平命名合约（flat named contract）}。在这一术语中使用“合约”表明合约是一等价值。“扁平”（flat）意味着数据集是内置数据原子类的一个子集；它们由一个断言描述，该断言接受所有的Racket值并产生布尔值。“命名”（named）部分表示我们想要做的事情，这就命名了这个合约，这样错误消息就变得明白易懂了：

@interaction[#:eval 
             contract-eval
             (module improved-bank-server racket
               (provide
                (contract-out
                 [deposit (-> (flat-named-contract
                               'amount
                               (λ (x)
                                 (and (number? x) (integer? x) (>= x 0))))
                              any)]))

               (define total 0)
               (define (deposit a) (set! total (+ a total))))]

通过这个小小的更改，错误消息变得相当易读：

@interaction[#:eval 
             contract-eval
             (require 'improved-bank-server)
             (deposit -10)]

@; not sure why, but if I define str directly to be the
@; expression below, then it gets evaluated before the 
@; expressions above it.
@(define str "huh?")

@(begin
   (set! str
         (with-handlers ((exn:fail? exn-message))
           (contract-eval '(deposit -10))))
   "")