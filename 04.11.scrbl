;04.11.scrbl
;4.11 准引用：quasiquote和`
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@(define qq (racket quasiquote))
@(define uq (racket unquote))

@title[#:tag "qq"]{准引用：@racket[quasiquote] and @racketvalfont{`}}

@racket[quasiquote]表类似于@racket[quote]：

@specform[(#,qq datum)]

然而，对于出现在@racket[_datum]的每个@racket[(#,uq _expr)]，@racket[_expr]被求值并产生一个替代@racket[unquote]子表的值。

@examples[
(eval:alts (#,qq (1 2 (#,uq (+ 1 2)) (#,uq (- 5 1))))
           `(1 2 ,(+ 1 2), (- 5 1)))
]

此表可用于编写根据特定模式生成列表的函数。

@examples[
(eval:alts (define (deep n)
             (cond
               [(zero? n) 0]
               [else
                (#,qq ((#,uq n) (#,uq (deep (- n 1)))))]))
           (define (deep n)
             (cond
               [(zero? n) 0]
               [else
                (quasiquote ((unquote n) (unquote (deep (- n 1)))))])))
(deep 8)
]

甚至可以以编程方式廉价地构造表达式。（当然，第9次就超出了10，你应该使用一个@seclink["macros"]{macro}来做这个（第10次是当你学习了一本像（@hyperlink["http://www.cs.brown.edu/~sk/Publications/Books/ProgLangs/"]{PLAI}）那样的教科书）。）

@examples[(define (build-exp n)
            (add-lets n (make-sum n)))
          
          (eval:alts
           (define (add-lets n body)
             (cond
               [(zero? n) body]
               [else
                (#,qq 
                 (let ([(#,uq (n->var n)) (#,uq n)])
                   (#,uq (add-lets (- n 1) body))))]))
           (define (add-lets n body)
             (cond
               [(zero? n) body]
               [else
                (quasiquote 
                 (let ([(unquote (n->var n)) (unquote n)])
                   (unquote (add-lets (- n 1) body))))])))
          
          (eval:alts
           (define (make-sum n)
             (cond
               [(= n 1) (n->var 1)]
               [else
                (#,qq (+ (#,uq (n->var n))
                         (#,uq (make-sum (- n 1)))))]))
           (define (make-sum n)
             (cond
               [(= n 1) (n->var 1)]
               [else
                (quasiquote (+ (unquote (n->var n))
                               (unquote (make-sum (- n 1)))))])))
          (define (n->var n) (string->symbol (format "x~a" n)))
          (build-exp 3)]

@racket[unquote-splicing]表和@racket[unquote]相似，但其@racket[_expr]必须产生一个列表，而且@racket[unquote-splicing]表必须出现在一个产生一个列表或向量的上下文里。顾名思义，生成的列表被拼接到它自己使用的上下文中。

@examples[
(eval:alts (#,qq (1 2 (#,(racket unquote-splicing) (list (+ 1 2) (- 5 1))) 5))
           `(1 2 ,@(list (+ 1 2) (- 5 1)) 5))
]

使用拼接，我们可以修改上面的示例表达式的构造，只需要一个@racket[let]表达式和一个单个@racket[+]表达式。

@examples[(eval:alts
           (define (build-exp n)
             (add-lets 
              n
              (#,qq (+ (#,(racket unquote-splicing) 
                        (build-list
                         n
                         (λ (x) (n->var (+ x 1)))))))))
           (define (build-exp n)
             (add-lets
              n
              (quasiquote (+ (unquote-splicing 
                              (build-list 
                               n
                               (λ (x) (n->var (+ x 1))))))))))
          (eval:alts
           (define (add-lets n body)
             (#,qq
              (let (#,uq
                    (build-list
                     n
                     (λ (n)
                       (#,qq 
                        [(#,uq (n->var (+ n 1))) (#,uq (+ n 1))]))))
                (#,uq body))))
           (define (add-lets n body)
             (quasiquote
              (let (unquote
                    (build-list 
                     n
                     (λ (n) 
                       (quasiquote
                        [(unquote (n->var (+ n 1))) (unquote (+ n 1))]))))
                (unquote body)))))
          (define (n->var n) (string->symbol (format "x~a" n)))
          (build-exp 3)]

如果一个@racket[quasiquote]表出现在一个封闭的@racket[quasiquote]表里，那这个内部的@racket[quasiquote]有效地删除@racket[unquote]和@racket[unquote-splicing]表的一层，结果第二层@racket[unquote]或@racket[unquote-splicing]表是必要的。

@examples[
(eval:alts (#,qq (1 2 (#,qq (#,uq (+ 1 2)))))
           `(1 2 (,(string->uninterned-symbol "quasiquote")
                  (,(string->uninterned-symbol "unquote") (+ 1 2)))))
(eval:alts (#,qq (1 2 (#,qq (#,uq (#,uq (+ 1 2))))))
           `(1 2 (,(string->uninterned-symbol "quasiquote")
                  (,(string->uninterned-symbol "unquote") 3))))
(eval:alts (#,qq (1 2 (#,qq ((#,uq (+ 1 2)) (#,uq (#,uq (- 5 1)))))))
           `(1 2 (,(string->uninterned-symbol "quasiquote")
                  ((,(string->uninterned-symbol "unquote") (+ 1 2))
                   (,(string->uninterned-symbol "unquote") 4)))))
]

上面的求值实际上不会像显示那样打印。相反，@racket[quasiquote]和@racket[unquote]的简写形式将被使用：@litchar{`}（即一个反引号）和@litchar{,}（即一个逗号）。同样的简写可在表达式中使用：

@examples[
`(1 2 `(,(+ 1 2) ,,(- 5 1)))
]

@racket[unquote-splicing]简写形式是@litchar[",@"]：

@examples[
`(1 2 ,@(list (+ 1 2) (- 5 1)))
]