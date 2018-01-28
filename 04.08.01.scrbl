;04.08.01.scrbl
;4.8.1 前置影响：begin
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{前置影响：@racket[begin]}

一个@racket[begin]表达式排序表达式：

@specform[(begin expr ...+)]{}

@racket[_expr]被顺序求值，并且除最后的@racket[_expr]结果外所有都被忽视。来自最后一个@racket[_expr]的结果作为@racket[begin]表的结果，它是相对于@racket[begin]表位于尾部的位置。

@defexamples[
(define (print-triangle height)
  (if (zero? height)
      (void)
      (begin
        (display (make-string height #\*))
        (newline)
        (print-triangle (sub1 height)))))
(print-triangle 4)
]

有多种表，比如@racket[lambda]或@racket[cond]支持一系列表达式甚至没有一个@racket[begin]。这样的状态有时被叫做有一个隐含的@deftech{implicit begin}。

@defexamples[
(define (print-triangle height)
  (cond
    [(positive? height)
     (display (make-string height #\*))
     (newline)
     (print-triangle (sub1 height))]))
(print-triangle 4)
]

@racket[begin]表在顶层（top level）、模块级（module level）或仅在内部定义之后作为@racket[body]是特殊的。在这些状态下，@racket[begin]的上下文被拼接到周围的上下文中，而不是形成一个表达式。
 
@defexamples[
(let ([curly 0])
  (begin
    (define moe (+ 1 curly))
    (define larry (+ 1 moe)))
  (list larry curly moe))
]

这种拼接行为主要用于宏（macro），我们稍后将在《宏》（@secref["macros"]）中讨论它。