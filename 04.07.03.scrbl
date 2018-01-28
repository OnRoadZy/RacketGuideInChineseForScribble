;04.07.03.scrbl
;4.7.3 约束测试：cond
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{约束测试：cond}

@racket[cond]表链接了一系列的测试以选择一个表达式结果。一个最近似的情况，@racket[cond]语法如下：

@specform[(cond [test-expr body ...+]
                ...)]

每个@racket[_test-expr]求值顺序求值。如果它产生@racket[#f]，相应的@racket[_body]被忽略，求值进程进入下一个@racket[_test-expr]。当一个@racket[_test-expr]产生一个真值，它的@racket[_body]求值产生的结果作为@racket[cond]表的结果。并不再进一步对@racket[_test-expr]求值。

在@racket[cond]最后的@racket[_test-expr]可用@racket[else]代替。在求值条件里，@racket[else]作为一个@racket[#t]的同义词提供。但它阐明了最后的从句是为了获取所有剩余的事例。如果@racket[else]没有被使用，而且可能没有@racket[_test-expr]产生真值；在这种情况下，该@racket[cond]表达式的结果是@|void-const|。

@examples[
(cond
 [(= 2 3) (error "wrong!")]
 [(= 2 2) 'ok])
(cond
 [(= 2 3) (error "wrong!")])
(cond
 [(= 2 3) (error "wrong!")]
 [else 'ok])
]

@def+int[
(define (got-milk? lst)
  (cond
    [(null? lst) #f]
    [(eq? 'milk (car lst)) #t]
    [else (got-milk? (cdr lst))]))
(got-milk? '(apple banana))
(got-milk? '(apple milk banana))
]

包括以上两种从句的@racket[cond]的完整语法：

@specform/subs[#:literals (else =>)
               (cond cond-clause ...)
               ([cond-clause [test-expr then-body ...+]
                             [else then-body ...+]
                             [test-expr => proc-expr]
                             [test-expr]])]

@racket[=>]变体获取@racket[_test-expr]真的结果并且传递给@racket[_proc-expr]的结果，@racket[_proc-expr]必须是有一个参数的函数。

@examples[
(define (after-groucho lst)
  (cond
    [(member "Groucho" lst) => cdr]
    [else (error "not there")]))

(after-groucho '("Harpo" "Groucho" "Zeppo"))
(after-groucho '("Harpo" "Zeppo"))
]

只包括一个@racket[_test-expr]的从句是很少使用的。它捕获@racket[_test-expr]的真值的结果，并简单地返回这个结果给整个@racket[cond]表达式。