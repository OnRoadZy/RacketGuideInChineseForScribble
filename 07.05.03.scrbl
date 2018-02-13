;07.05.03.scrbl
;7.5.3 检查数据结构的特性
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt"
          "utils.rkt"
          (for-label racket/contract))

@title[#:tag "lazy-contracts"]{检查数据结构的特性}

用@racket[struct/c]编写的合约会立即检查数据结构的字段，但是有时这会对程序本身的性能造成灾难性的影响，而这个程序本身并不检查整个数据结构。

作为一个例子，考虑二叉搜索树搜索算法。一个二叉搜索树就像一个二叉树，除了这些数值被组织在树中，以便快速搜索树。特别是，对于树中的每个内部节点，左边子树中的所有数值都小于节点中的数值，而右子树中的所有数值都大于节点中的数值。

我们可以实现搜索函数@racket[in?]，它利用了二叉搜索树结构的优越性。

@racketmod[
racket

(struct node (val left right))
  
(code:comment "determines if `n' is in the binary search tree `b',")
(code:comment "exploiting the binary search tree invariant")
(define (in? n b)
  (cond
    [(null? b) #f]
    [else (cond
            [(= n (node-val b))
             #t]
            [(< n (node-val b))
             (in? n (node-left b))]
            [(> n (node-val b))
             (in? n (node-right b))])]))

(code:comment "a predicate that identifies binary search trees")
(define (bst-between? b low high)
  (or (null? b)
      (and (<= low (node-val b) high)
           (bst-between? (node-left b) low (node-val b))
           (bst-between? (node-right b) (node-val b) high))))

(define (bst? b) (bst-between? b -inf.0 +inf.0))
  
(provide (struct-out node))
(provide (contract-out
          [bst? (any/c . -> . boolean?)]
          [in? (number? bst? . -> . boolean?)]))
]

在一个完整的二叉搜索树中，这意味着@racket[in?]函数只需探索一个对数节点。

对@racket[in?]的合约保证其输入是二叉搜索树。但经过仔细的思考发现，该合约违背了二叉搜索树算法的目的。特别是，考虑到@racket[in?]函数内部的@racket[cond]。这是@racket[in?]函数得到它的速度的地方：它避免在每次递归调用时搜索整个子树。现在把它与@racket[bst-between?]函数相比。在这种情况下，它返回@racket[#t]，它遍历整个树，意味@racket[in?]的加速没有实现。

为了解决这个问题，我们可以采用一种新的策略来检查二叉搜索树合约。特别是，如果我们只检查了@racket[in?]接受的节点上的合约，我们仍然可以保证树至少部分地成形了，但是没有改变复杂性。

要做到这一点，我们需要使用@racket[struct/dc]定义@racket[bst-between?]。像@racket[struct/c]一样，@racket[struct/dc]定义了一个结构的合约。与@racket[struct/c]不同，它允许字段被标记为惰性，这样当匹配选择器被调用时，才检查这些合约。此外，它不允许将可变字段标记为惰性。

@racket[struct/dc]表接受结构的每个字段的一个合约，并返回一个结构的合约。更有趣的是，@racket[struct/dc]允许我们编写依赖的合约，也就是说，某些字段上的合约依赖于其它字段的值。我们可以用这个去定义二叉搜索树合约：

@racketmod[
racket

(struct node (val left right))

(code:comment "determines if `n' is in the binary search tree `b'")
(define (in? n b) ... as before ...)

(code:comment "bst-between : number number -> contract")
(code:comment "builds a contract for binary search trees")
(code:comment "whose values are between low and high")
(define (bst-between/c low high)
  (or/c null?
        (struct/dc node [val (between/c low high)]
                        [left (val) #:lazy (bst-between/c low val)]
                        [right (val) #:lazy (bst-between/c val high)])))

(define bst/c (bst-between/c -inf.0 +inf.0))

(provide (struct-out node))
(provide (contract-out
          [bst/c contract?]
          [in? (number? bst/c . -> . boolean?)]))
]

一般来说，每个@racket[struct/dc]的使用都必须命名字段，然后为每个字段指定合约。在上面的@racket[val]字段是一个接受@racket[low]与@racket[high]之间的值的合约。@racket[left]和@racket[right]的字段依赖于它们的第二个子表达式所表示的@racket[val]值。他们也用@racket[#:lazy]关键字标记，以表明他们只有当合适的存取被结构实例调用应该被检查。它们的合约是通过递归调用@racket[bst-between/c]函数来构建的。综合起来，这个合约保证了@racket[bst-between?]函数在原始示例中检查同样的事情，但这里的检查只发生在@racket[in?]探索这个树时。

虽然这个合约提高了@racket[in?]的性能，把它恢复到合约较少版本的对数行为上，但它仍然强加了相当大的恒定开销。因此，合约库还提供了@racket[define-opt/c]，它通过优化它的主体来降低常数因子。它的形态和上面的@racket[define]一样。它希望它的主体是一个合约，然后优化该合约。

@racketblock[
(define-opt/c (bst-between/c low high)
  (or/c null?
        (struct/dc node [val (between/c low high)]
                        [left (val) #:lazy (bst-between/c low val)]
                        [right (val) #:lazy (bst-between/c val high)])))
]