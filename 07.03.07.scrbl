;07.03.07.scrbl
;7.3.7 检查状态变化
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "utils.rkt"
          (for-label framework/framework
                     racket/contract
                     racket/gui))

@title[#:tag "arrow-d-eval-order"]{检查状态变化}

@racket[->i]合约的组合也可以确保函数按照一定的约束只修改状态。例如，考虑这个合约（它是从框架中函数@racket[preferences:add-panel]首选项中添加的略微简化的版本）：

@racketblock[
(->i ([parent (is-a?/c area-container-window<%>)])
      [_ (parent)
       (let ([old-children (send parent get-children)])
         (λ (child)
           (andmap eq?
                   (append old-children (list child))
                   (send parent get-children))))])
]

它表示函数接受单个参数，命名为@racket[parent]并且@racket[parent]必须是匹配接口@racket[area-container-window<%>]。

范围合约确保函数只通过在列表前面添加一个新的子代来修改@racket[parent]的子类。这是通过使用@racket[_]代替正常的标识符，它告诉合约库的范围合约并不依赖于任何结果的值，因此合约计算表达式后，@racket[_]库在函数被调用时，而不是返回时。因此，调用@racket[get-children]方法之前发生在合约下的函数调用。当合约下的函数返回时，它的结果作为@racket[child]传递，并且合约确保函数返回后的child与函数调用之前的child相同，但是在列表前面还有一个child。

要看一个集中在这一点上的无实用价值的示例的差异，请考虑这个程序：

@racketmod[
racket
(define x '())
(define (get-x) x)
(define (f) (set! x (cons 'f x)))
(provide
 (contract-out
  [f (->i () [_ (begin (set! x (cons 'ctc x)) any/c)])]
  [get-x (-> (listof symbol?))]))
]

如果你需要这个模块，调用@racket[f]，然后@racket[get-x]结果会@racket['(f ctc)]。相反，如果 @racket[f]的合约是

@racketblock[(->i () [res (begin (set! x (cons 'ctc x)) any/c)])]

（只改变下划线@racket[res]），然后 @racket[get-x]结果会是@racket['(ctc f)]。