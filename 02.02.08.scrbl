;02.02.08.scrbl
;2.2.8 用define、let和let*实现局部绑定
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          "guide-utils.rkt")

@(define fun-defn2-stx
   @BNF-seq[@litchar{(}@litchar{define}
            @litchar{(} @nonterm{id}
            @kleenestar{@nonterm{id}}
            @litchar{)}
            @kleenestar{@nonterm{definition}}
            @kleeneplus{@nonterm{expr}}
            @litchar{)}])
@(define lambda2-expr-stx
   @BNF-seq[@litchar{(}
            @litchar{lambda}
            @litchar{(}
            @kleenestar{@nonterm{id}}
            @litchar{)}
            @kleenestar{@nonterm{definition}}
            @kleeneplus{@nonterm{expr}}
            @litchar{)}])
@(define (make-let-expr-stx kw)
   @BNF-seq[@litchar{(}
            kw
            @litchar{(}
            @kleenestar{@BNF-group[@litchar{[}
                                   @nonterm{id}
                                   @nonterm{expr}
                                   @litchar{]}]}
            @litchar{)}
            @kleeneplus{@nonterm{expr}}
            @litchar{)}])
@(define let-expr-stx
   (make-let-expr-stx
    @litchar{let}))


@title{用@racket[define]、@racket[let]和@racket[let*]实现局部绑定}

现在是收起我们的Racket语法的另一个简化的时候了。在函数体中，定义可以出现在函数体表达式之前：

@racketblock[
 #,fun-defn2-stx
 #,lambda2-expr-stx]

函数体开始时的定义在函数体中是局部的。

@defexamples[
 (define (converse s)
   (define (starts? s2)
     (code:comment @#,t{local to @racket[converse]})
     (define len2 (string-length s2))
     (code:comment @#,t{local to @racket[starts?]})
     (and (>= (string-length s) len2)
          (equal? s2 (substring s 0 len2))))
   (cond
     [(starts? "hello") "hi!"]
     [(starts? "goodbye") "bye!"]
     [else "huh?"]))
 (converse "hello!")
 (converse "urp")
 (eval:alts (code:line starts?
                       (code:comment @#,t{outside of @racket[converse], so...}))
            (parameterize ([current-namespace (make-base-namespace)]) (eval 'starts?)))]
 创建本地绑定的另一种方法是@racket[let]表。@racket[let]的优点是它可以在任何表达式位置使用。另外，@racket[let]同时可以绑定多个标识符，而不是每个标识符都需要单独用@racket[define]定义。
 
@racketblock[#,let-expr-stx]
 
每个约束条款是一个@nonterm{id}和@nonterm{expr}方括号包围，和之后的从句表达的@racket[let]函数体。在每一个条款，该@nonterm{id}势必对应与函数体的@nonterm{expr}结果。

@interaction[
 (let ([x (random 4)]
       [o (random 4)])
   (cond
     [(> x o) "X wins"]
     [(> o x) "O wins"]
     [else "cat's game"]))]

@racket[let]表的绑定仅在@racket[let]的函数体中可用，因此绑定子句不能互相引用。相反，@racket[let*]表允许后面的子句使用前面的绑定：

@interaction[
 (let* ([x (random 4)]
        [o (random 4)]
        [diff (number->string (abs (- x o)))])
   (cond
     [(> x o) (string-append "X wins by " diff)]
     [(> o x) (string-append "O wins by " diff)]
     [else "cat's game"]))]