;02.02.05.scrbl
;2.2.5 条件表达式if、and、or和cond
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          "guide-utils.rkt")

@(define if-expr-stx
   @BNF-seq[@litchar{(}
            @litchar{if}
            @nonterm{expr}
            @nonterm{expr}
            @nonterm{expr}
            @litchar{)}])
@(define and-expr-stx
   @BNF-seq[@litchar{(}
            @litchar{and}
            @kleenestar{@nonterm{expr}}
            @litchar{)}])
@(define or-expr-stx
   @BNF-seq[@litchar{(}
            @litchar{or}
            @kleenestar{@nonterm{expr}}
            @litchar{)}])
@(define cond-expr-stx
   @BNF-seq[@litchar{(}
            @litchar{cond}
            @kleenestar{@BNF-group[@litchar{[}
                                   @nonterm{expr}
                                   @kleenestar{@nonterm{expr}}
                                   @litchar{]}]}
            @litchar{)}])

@title[#:tag "if-and-or-cond"]{条件表达式@racket[if]、@racket[and]、@racket[or]和@racket[cond]}

以下是一个最简单的表达式是@racket[if]条件：

@racketblock[
 #,if-expr-stx]

第一个@nonterm{expr}总是被求值。如果它产生一个非@racket[#f]值，那么第二个@nonterm{expr}被求值并作为整个@racket[if]表达式的结果，否则第三个@nonterm{expr}被求值并作为结果。

@examples[
 (if (> 2 3)
     "bigger"
     "smaller")]

@def+int[
 (define (reply s)
   (if (equal? "hello" (substring s 0 5))
       "hi!"
       "huh?"))
 (reply "hello racket")
 (reply "\u03BBx:(\u03BC\u03B1.\u03B1\u2192\u03B1).xx")]

复杂的条件可以由嵌套的@racket[if]表达式构成。例如，当给定非字符串时，可以使@racket[reply]函数工作：

@racketblock[
 (define (reply s)
   (if (string? s)
       (if (equal? "hello" (substring s 0 5))
           "hi!"
           "huh?")
       "huh?"))]
      
而不是复制@racket["huh?"]事例，这个函数这样写会更好：

@racketblock[
 (define (reply s)
   (if (if (string? s)
           (equal? "hello" (substring s 0 5))
           #f)
       "hi!"
       "huh?"))]

是这些嵌套的@racket[if]很难读。Racket通过@racket[and]和@racket[or]表提供了更多的更易读的快捷表示，它可以和任意数量的表达式搭配：

@racketblock[
 #,and-expr-stx
 #,or-expr-stx]

@racket[and]表中断情况：当表达式返回@racket[#f]，它停止并返回@racket[#f]，否则它会运行。@racket[or]表遇到一个真的结果时，同样的产生中断情况。

@defexamples[
 (define (reply s)
   (if (and (string? s)
            (>= (string-length s) 5)
            (equal? "hello" (substring s 0 5)))
       "hi!"
       "huh?"))
 (reply "hello racket")
 (reply 17)]

嵌套@racket[if]的另一种常见模式是一个序列测试，每个测试都有自己的结果：

@racketblock[
 (define (reply-more s)
   (if (equal? "hello" (substring s 0 5))
       "hi!"
       (if (equal? "goodbye" (substring s 0 7))
           "bye!"
           (if (equal? "?" (substring s (- (string-length s) 1)))
               "I don't know"
               "huh?"))))]

对一个序列的测试的快捷形式是@racket[cond]表：

@racketblock[
 #,cond-expr-stx]

一个@racket[cond]表包含了括号之间的一个序列的分句表。在每一个分句表，第一个@nonterm{expr}是测试表达式。如果它产生真值，那么剩下的 @nonterm{expr}从句表被求值，并在这些分从句的最后一个提供整个@racket[cond]表达结果，同时其余的从句表被忽略。如果测试 @nonterm{expr}产生@racket[#f]，那么从句表剩余的 @nonterm{expr}被忽视，并继续下一个从句表求值。最后一项分句表可以使用@racket[else]作为一个@racket[#t]测试表达式的相同意义。

使用@racket[cond]，@racket[reply-more]函数可以更清楚地写成如下形式：

 @def+int[
 (define (reply-more s)
   (cond
     [(equal? "hello" (substring s 0 5))
      "hi!"]
     [(equal? "goodbye" (substring s 0 7))
      "bye!"]
     [(equal? "?" (substring s (- (string-length s) 1)))
      "I don't know"]
     [else "huh?"]))
 (reply-more "hello racket")
 (reply-more "goodbye cruel world")
 (reply-more "what is your favorite color?")
 (reply-more "mine is lime green")]

对于@racket[cond]从句表的方括号的使用是一种惯例。在Racket中，圆括号和方括号实际上是可互换的，只要@litchar{(}匹配@litchar{)}或@litchar{[}匹配@litchar{]}即可。在一些关键的地方使用方括号可以使Racket代码更易读。