;05.05.scrbl
;5.5 结构的比较
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          "guide-utils.rkt"
          (for-label racket/dict racket/serialize))

@(define posn-eval (make-base-eval))

@title[#:tag "struct-equal"]{结构的比较}

一个通用的@racket[equal?]比较自动出现在透明的结构类型的字段上，但是@racket[equal?]默认仅针对不透明结构类型的实例标识：

(struct glass (width height) #:transparent)

> (equal? (glass 1 2) (glass 1 2))
#t

@def+int[
#:eval posn-eval
(struct glass (width height) #:transparent)
(equal? (glass 1 2) (glass 1 2))
]
@def+int[
#:eval posn-eval
(struct lead (width height))
(define slab (lead 1 2))
(equal? slab slab)
(equal? slab (lead 1 2))
]

通过@racket[equal?]支持实例比较而不需要使结构型透明，你可以使用@racket[#:methods]关键字、@racket[gen:equal+hash]并执行三个方法来实现：

@def+int[
#:eval posn-eval
(struct lead (width height)
  #:methods
  gen:equal+hash
  [(define (equal-proc a b equal?-recur)
     (code:comment @#,t{compare @racket[a] and @racket[b]})
     (and (equal?-recur (lead-width a) (lead-width b))
          (equal?-recur (lead-height a) (lead-height b))))
   (define (hash-proc a hash-recur)
     (code:comment @#,t{compute primary hash code of @racket[a]})
     (+ (hash-recur (lead-width a))
        (* 3 (hash-recur (lead-height a)))))
   (define (hash2-proc a hash2-recur)
     (code:comment @#,t{compute secondary hash code of @racket[a]})
     (+ (hash2-recur (lead-width a))
             (hash2-recur (lead-height a))))])
(equal? (lead 1 2) (lead 1 2))
]

列表中的第一个函数实现对两个@racket[lead]的@racket[equal?]测试；函数的第三个参数是用来代替@racket[equal?]实现递归的相等测试，以便这个数据循环可以被正确处理。其它两个函数计算用于@tech{哈希表（hash tables）}的一级和二级哈希代码：

@interaction[
#:eval posn-eval
(define h (make-hash))
(hash-set! h (lead 1 2) 3)
(hash-ref h (lead 1 2))
(hash-ref h (lead 2 1))
]

这第一个函数提供@racket[gen:equal+hash]，不需要递归比较结构的字段。例如，表示一个集合的结构类型可以通过检查集合的成员是相同的来执行相等操作，独立于内部表示的的元素顺序来实现相等。只要注意哈希函数对任何两个假定相等的结构类型都会产生相同的值。

@close-eval[posn-eval]