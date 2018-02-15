;05.06.scrbl
;5.6 结构类型的生成性
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          "guide-utils.rkt"
          (for-label racket/dict racket/serialize))

@title[#:tag "structure-type-generativity"]{结构类型的生成性}

每次对一个@racket[struct]表求值时，它就生成一个与所有现有结构类型不同的结构类型，即使某些其他结构类型具有相同的名称和字段。

这种生成性对执行抽象和执行程序是有用的，就像口译员，但小心放置@racket[struct]表被多次求值的位置。

@defexamples[
(define (add-bigger-fish lst)
  (struct fish (size) #:transparent) (code:comment #,(t "new every time"))
  (cond
   [(null? lst) (list (fish 1))]
   [else (cons (fish (* 2 (fish-size (car lst))))
               lst)]))

(add-bigger-fish null)
(add-bigger-fish (add-bigger-fish null))
]
@defs+int[
[(struct fish (size) #:transparent)
 (define (add-bigger-fish lst)
   (cond
    [(null? lst) (list (fish 1))]
    [else (cons (fish (* 2 (fish-size (car lst))))
                lst)]))]
(add-bigger-fish (add-bigger-fish null))
]