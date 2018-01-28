;02.03.04.scrbl
;2.3.4 递归和迭代
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          racket/list
          "guide-utils.rkt"
          (for-label racket/list))

@(define list-eval (make-base-eval))
@(define step @elem{=})

@title{递归和迭代}

@racket[my-length]和@racket[my-map]示例表明迭代只是递归的一个特例。在许多语言中，尽可能地将尽可能多的计算合并成迭代形式是很重要的。否则，性能会变差，适度大的输入都会导致堆栈溢出。同样地，在Racket中，有时很重要的一点是要确保在易于计算的常数空间中使用尾递归避免@math{O(n)}空间消耗。

同时，在Racket里递归不会导致特别差的性能，而且没有堆栈溢出那样的事情；如果计算涉及到太多的上下文，你可能耗尽内存，但耗尽内存通常需要比可能触发其他语言中的堆栈溢出更多数量级以上的更深层次的递归。基于这些考虑因素，加上尾递归程序自动与循环运行的事实相结合，导致Racket程序员接受递归形式而不是避免它们。

例如，假设您希望从列表中删除连续的重复项。虽然这样的函数可以写成一个循环，每次迭代都记得以前的元素，但Racket程序员更可能只写以下内容：

@def+int[
 #:eval list-eval
 (define (remove-dups l)
   (cond
     [(empty? l) empty]
     [(empty? (rest l)) l]
     [else
      (let ([i (first l)])
        (if (equal? i (first (rest l)))
            (remove-dups (rest l))
            (cons i (remove-dups (rest l)))))]))
 (remove-dups (list "a" "b" "b" "b" "c" "c"))]

一般来说，这个函数为长度@math{n}的输入列表消耗@math{O(n)}空间，但这很好，因为它产生一个@math{O(n)}结果。如果输入列表恰巧是连续重复的，然后得到的列表可以比@math{O(n)}小得多——而且@racket[remove-dups]也将使用比@math{O(n)}更少的空间！原因是当函数放弃重复，它返回一个@racket[remove-dups]的直接调用结果，所以尾部调用“优化”加入：

@racketblock[
 #||# (remove-dups (list "a" "b" "b" "b" "b" "b"))
 #,step (cons "a" (remove-dups (list "b" "b" "b" "b" "b")))
 #,step (cons "a" (remove-dups (list "b" "b" "b" "b")))
 #,step (cons "a" (remove-dups (list "b" "b" "b")))
 #,step (cons "a" (remove-dups (list "b" "b")))
 #,step (cons "a" (remove-dups (list "b")))
 #,step (cons "a" (list "b"))
 #,step (list "a" "b")]