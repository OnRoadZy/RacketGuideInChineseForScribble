;02.02.07.scrbl
;2.2.7 匿名函数与lambda
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          "guide-utils.rkt")

@(define ex-eval (make-base-eval))
@(define lambda-expr-stx
   @BNF-seq[@litchar{(}
            @litchar{lambda}
            @litchar{(}
            @kleenestar{@nonterm{id}}
            @litchar{)}
            @kleeneplus{@nonterm{expr}}
            @litchar{)}])

@title[#:tag "anonymous-functions"]{匿名函数与@racket[lambda]}

如果你必须命名你所有的数值，那Racket的编程就太乏味了。替换@racket[(+ 1 2)]的写法，你得这样写：

@interaction[
 (define a 1)
 (define b 2)
 (+ a b)]

事实证明，要命名所有函数也可能很乏味。例如，您可能有个函数 @racket[twice]，带了一个函数和一个参数。如果你已经有了函数的名字那么使用 @racket[twice]是比较方便的，如@racket[sqrt]：

@def+int[
 #:eval ex-eval
 (define (twice f v)
   (f (f v)))
 (twice sqrt 16)]

如果您想调用尚未定义的函数，您可以定义它，然后将其传递给@racket[twice]：

@def+int[
 #:eval ex-eval
 (define (louder s)
   (string-append s "!"))
 (twice louder "hello")]

但是如果对 @racket[twice]的调用是唯一使用 @racket[louder]的地方，却还要写一个完整的定义是很可惜的。在Racket中，可以使用 @racket[lambda]表达式直接生成函数。 @racket[lambda]表后面是函数参数的标识符，然后是函数的体表达式：

@racketblock[#,lambda-expr-stx]

求值@racket[lambda]表本身即产生一个函数：

@interaction[(lambda (s) (string-append s "!"))]

使用@racket[lambda]，上述对@racket[twice]的调用可以重写为：

@interaction[
 #:eval ex-eval
 (twice (lambda (s) (string-append s "!"))
        "hello")
 (twice (lambda (s) (string-append s "?!"))
        "hello")]

@racket[lambda]的另一个用途是作为生成函数的函数结果：

@def+int[
 #:eval ex-eval
 (define (make-add-suffix s2)
   (lambda (s) (string-append s s2)))
 (twice (make-add-suffix "!") "hello")
 (twice (make-add-suffix "?!") "hello")
 (twice (make-add-suffix "...") "hello")]

Racket是一个词法作用域（@defterm{lexically scoped}）的语言，这意味着函数中的@racket[s2]通过@racket[make-add-suffix]总是指创建该函数调用的参数返回。换句话说，@racket[lambda]生成的函数“记住”了右边的@racket[s2]：

@interaction[
 #:eval ex-eval
 (define louder (make-add-suffix "!"))
 (define less-sure (make-add-suffix "?"))
 (twice less-sure "really")
 (twice louder "really")]

到目前为止我们已经提到了表@racket[(define
@#,nonterm{id} @#,nonterm{expr})]的定义。作为“非函数的定义“。“这种表征是误导性的，因为@nonterm{expr}可以是一个@racket[lambda]表，在这种情况下，定义是等效于使用“函数（function）”的定义形式。例如，下面两个@racket[louder]的定义是等价的：

@defs+int[
 #:eval ex-eval
 [(define (louder s)
    (string-append s "!"))
  code:blank
  (define louder
    (lambda (s)
      (string-append s "!")))]
 louder]

注意，第二种情况下@racket[louder]表达式是用@racket[lambda]写成的“匿名（anonymous）”函数，但如果可能的话，编译器推断出一个名称，无论如何，使打印和错误报告尽可能地有信息。
