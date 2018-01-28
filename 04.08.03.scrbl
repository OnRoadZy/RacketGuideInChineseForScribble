;04.08.03.scrbl
;4.8.3 if影响：when和unless
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{if影响：@racket[when]和@racket[unless]}

@racket[when]表将@racket[if]样式条件与“then”子句并且没有“else”子句的排序相结合：
 
@specform[(when test-expr then-body ...+)]
 
如果@racket[_test-expr]产生一个真值，那么所有的@racket[_then-body]被求值。最后一个@racket[_then-body]的结果是@racket[when]表的结果。否则，没有@racket[_then-body]被求值而且结果是@|void-const|。

@racket[unless]是相似的：

@specform[(unless test-expr then-body ...+)]

不同的是，@racket[_test-expr]结果是相反的：如果@racket[_test-expr]结果为@racket[#f]时@racket[_then-body]被求值。

@defexamples[
(define (enumerate lst)
  (if (null? (cdr lst))
      (printf "~a.\n" (car lst))
      (begin
        (printf "~a, " (car lst))
        (when (null? (cdr (cdr lst)))
          (printf "and "))
        (enumerate (cdr lst)))))
(enumerate '("Larry" "Curly" "Moe"))
]

@def+int[
(define (print-triangle height)
  (unless (zero? height)
    (display (make-string height #\*))
    (newline)
    (print-triangle (sub1 height))))
(print-triangle 4)
]