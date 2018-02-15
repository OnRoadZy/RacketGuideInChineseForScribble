;04.05.04.scrbl
;4.5.4 内部定义
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "intdefs"]{内部定义}

当句法表的语法指定@racket[_body]，那相应的表可以是定义或表达式。作为一个@racket[_body]的定义是一个内部定义@defterm{internal definition}。

一个@racket[_body]序列中的表达式和内部定义可以混合，只要最后一个@racket[_body]是表达式。

例如， @racket[lambda]的语法是：

@specform[
(lambda gen-formals
  body ...+)
]
  
下面是语法的有效实例：

@racketblock[
(lambda (f)
  (code:comment @#,elem{没有定义})
  (printf "running\n")
  (f 0))

(lambda (f)
  (code:comment @#,elem{一个定义})
  (define (log-it what)
    (printf "~a\n" what))
  (log-it "running")
  (f 0)
  (log-it "done"))

(lambda (f n)
  (code:comment @#,elem{两个定义})
  (define (call n)
    (if (zero? n)
        (log-it "done")
        (begin
          (log-it "running")
          (f n)
          (call (- n 1)))))
  (define (log-it what)
    (printf "~a\n" what))
  (call n))
]

特定的@racket[_body]序列中的内部定义是相互递归的，也就是说，只要引用在定义发生之前没有实际求值，那么任何定义都可以引用任何其他定义。如果过早引用定义，则会出现错误。

@defexamples[
(define (weird)
  (define x x)
  x)
(weird)
]
 
一系列的内部定义只使用@racket[define]很容易转换为等效的@racket[letrec]表（如同在下一节介绍的内容）。然而，其他的定义表可以表现为一个@racket[_body]，包括@racket[define-values]、 @racket[struct]（见《程序员定义的数据类型》（@secref["define-struct"]））或@racket[define-syntax]（见《宏》（@secref["macros"]））。