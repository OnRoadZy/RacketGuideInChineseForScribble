;02.03.03.scrbl
;2.3.3 尾递归
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          racket/list
          "guide-utils.rkt"
          (for-label racket/list))

@(define step @elem{=})

@title{尾递归}

前面@racket[my-length]和@racket[my-map]自定义函数都在@math{O(n)}的时间内运行一个 @math{n}长度的列表。很显然能够想象@racket[(my-length (list "a" "b" "c"))]必须如下求值：

@racketblock[
#||# (my-length (list "a" "b" "c"))
#,step (+ 1 (my-length (list "b" "c")))
#,step (+ 1 (+ 1 (my-length (list "c"))))
#,step (+ 1 (+ 1 (+ 1 (my-length (list)))))
#,step (+ 1 (+ 1 (+ 1 0)))
#,step (+ 1 (+ 1 1))
#,step (+ 1 2)
#,step 3]

对于带有@math{n}个元素的列表，求值将叠加@math{n}@racket[(+ 1 ...)]，并且直到列表用完时最后才添加它们。

您可以通过一路求和避免堆积添加。要以这种方式累积长度，我们需要一个函数，它既可以操作列表，也可以操作当前列表的长度；下面的代码使用一个局部函数@racket[iter]，在一个参数@racket[len]中累积长度：

@racketblock[
 (define (my-length lst)
   (code:comment @#,t{local function @racket[iter]:})
   (define (iter lst len)
     (cond
       [(empty? lst) len]
       [else (iter (rest lst) (+ len 1))]))
   (code:comment @#,t{body of @racket[my-length] calls @racket[iter]:})
   (iter lst 0))]

现在求值过程看起来像这样：

@racketblock[
 #||# (my-length (list "a" "b" "c"))
 #,step (iter (list "a" "b" "c") 0)
 #,step (iter (list "b" "c") 1)
 #,step (iter (list "c") 2)
 #,step (iter (list) 3)
 3]

修正后的@racket[my-length]函数在恒定的空间中运行，正如上面的求值步骤所表明的那样。也就是说，当函数调用的结果，比如@racket[(iter (list "b" "c") 1)]，确切地说是其他函数调用的结果，例如@racket[(iter (list "c"))]，那么第一个函数不需要等待第二个函数回绕，因为那样会为了不恰当的原因占用空间。

这种求值行为有时称为@idefterm{”尾部调用优化(tail-call
optimization)“}，但它在Racket里不仅仅是一种“优化”，它是代码运行方式的保证。更确切地说，相对于另一表达式的@deftech{尾部(tail position)}位置表达式在另一表达式上不占用额外的计算空间。

在 @racket[my-map]例子中，@math{O(n)}空间复杂度是合理的，因为它必须生成@math{O(n)}的结果。不过，您可以通过累积结果列表来减少常数因子。唯一的问题是累积的列表将是向后的，所以你必须在结尾处反转它：

@racketblock[
 (define (my-map f lst)
   (define (iter lst backward-result)
     (cond
       [(empty? lst) (reverse backward-result)]
       [else (iter (rest lst)
                   (cons (f (first lst))
                         backward-result))]))
   (iter lst empty))]
  
事实证明，如果你这样写：

@racketblock[
 (define (my-map f lst)
   (for/list ([i lst])
     (f i)))]
    
然后函数中的@racket[for/list]表扩展到和@racket[iter]函数局部定义和使用在本质上相同的代码。区别仅仅是句法上的便利。