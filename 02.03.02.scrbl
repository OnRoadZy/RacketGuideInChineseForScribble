;02.03.02.scrbl
;2.3.2 从头开始列表迭代
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          racket/list
          "guide-utils.rkt"
          (for-label racket/list))

@(define list-eval (make-base-eval))

@title{从头开始列表迭代}

尽管@racket[map]和其他迭代函数是预定义的，但它们在任何有趣的意义上都不是原始的。使用少量列表原语即能编写等效迭代。

由于Racket列表是一个链表，在非空列表中的两个核心操作是:
@itemize[
 @item{@racket[first]：取得列表上的第一件事物；}
 @item{@racket[rest]：获取列表的其余部分。}]

@examples[
 #:eval list-eval
 (first (list 1 2 3))
 (rest (list 1 2 3))]

为链表添加一个新的节点——确切地说，添加到列表的前面——使用@racket[cons]函数，那是“construct”（构造）的缩写。要得到一个空列表用于开始，用@racket[empty]来构造：

@interaction[
 #:eval list-eval
 empty
 (cons "head" empty)
 (cons "dead" (cons "head" empty))]

要处理列表，你需要能够区分空列表和非空列表，因为@racket[first]和@racket[rest]只在非空列表上工作。@racket[empty?]函数检测空列表，@racket[cons?]检测非空列表：

@interaction[
 #:eval list-eval
 (empty? empty)
 (empty? (cons "head" empty))
 (cons? empty)
 (cons? (cons "head" empty))]

通过这些片段，您可以编写自己的@racket[length]函数、@racket[map]函数以及更多的函数的版本。

@defexamples[
 #:eval list-eval
 (define (my-length lst)
   (cond
     [(empty? lst) 0]
     [else (+ 1 (my-length (rest lst)))]))
 (my-length empty)
 (my-length (list "a" "b" "c"))]

@def+int[
 #:eval list-eval
 (define (my-map f lst)
   (cond
     [(empty? lst) empty]
     [else (cons (f (first lst))
                 (my-map f (rest lst)))]))
 (my-map string-upcase (list "ready" "set" "go"))]

如果上述定义的派生对你来说难以理解，建议去读《如何设计程序》（ @|HtDP|）。如果您只对使用递归调用而不是循环结构表示疑惑，那就继续往后读。