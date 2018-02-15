;02.02.01.scrbl
;2.2.1 定义
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          "guide-utils.rkt")

@(define ex-eval (make-base-eval))

@(define val-defn-stx
   @BNF-seq[@litchar{(}@litchar{define} @nonterm{id} @nonterm{expr} @litchar{)}])
@(define fun-defn-stx
   @BNF-seq[@litchar{(}@litchar{define} @litchar{(} @nonterm{id} @kleenestar{@nonterm{id}} @litchar{)}
                  @kleeneplus{@nonterm{expr}} @litchar{)}])

@title[#:tag "definitions"]{定义}

表的定义：

@racketblock[@#,val-defn-stx]

绑定@nonterm{id}到@nonterm{expr}的结果，而

@racketblock[@#,fun-defn-stx]

绑定第一个定@nonterm{ID}到一个函数（也叫程序），以参数作为命名定@nonterm{ID}，对函数的实例，该定@nonterm{expr}是函数的函数体。当函数被调用时，它返回最后一个定@nonterm{expr}的结果。

@defexamples[
 #:eval ex-eval
 (code:line (define pie 3)
            (code:comment @#,t{定义 @racket[pie]为@racket[3]}))
 
 (code:line (define (piece str)
            (code:comment @#,t{定义 @racket[pie]为一个有一个参数})
            (substring str 0 pie))
            (code:comment @#,t{的函数}))
            pie
            (piece "key lime")]

在封装下，函数定义实际上与非函数定义相同，函数名不需要在函数调用中使用。函数只是另一种类型的值，尽管打印形式必须比数字或字符串的打印形式更不完整。

@defexamples[
 #:eval ex-eval
 
 piece
 substring]

函数定义可以包含函数体的多个表达式。在这种情况下，在调用函数时只返回最后一个表达式的值。其他表达式只对一些副作用进行求值，比如打印这些。

@defexamples[
 #:eval ex-eval
 
 (define (bake flavor)
   (printf "pre-heating oven...\n")
   (string-append flavor " pie"))
 
 (bake "apple")]

Racket程序员更喜欢避免副作用，所以一个定义通常只有一个表达式。这是重要的，但是，了解多个表达式在定义体内是被允许的，因为它解释了为什么以下@racket[nobake]函数未在其结果中包含它的参数：

@def+int[
#:eval ex-eval

 (define (nobake flavor)
   string-append flavor "jello")

 (nobake "green")]

在nobake，没有括号包括string-append给"jello"，那么他们是三个单独的表达而不是函数调用表达式。string-append表达式和flavor被求值，但结果没有被使用。相反，该函数的结果是最终的表达式"jello"。