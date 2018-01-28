;03.02.scrbl
;3.2 数值（Number）
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{数值（Number）}

Racket的@deftech{数值（number）}可以是精确的也可以是不精确的：

@itemize[
 @item{一个@defterm{精确}的数字是：
         
  @itemize[
 @item{一个任意大的或小的整数，比如：@racket[5]，@racket[99999999999999999]或@racket[-17]；}
 @item{一个有理数，即精确的两个任意小的或大的整数比，比如：@racket[1/2]，@racket[99999999999999999/2]或@racket[-3/4]；}
 @item{一个复数，带有精确的实部和虚部（即虚部不为零），比如：@racket[1+2i]或@racket[1/2+3/4i]。}]}

@item{一个 @defterm{不精确}的数字是：

    @itemize[
 @item{一个数的一个IEEE浮点表示，比如：@racket[2.0]或@racket[3.14e87]，其中IEEE无穷大和非数书写为：@racket[+inf.0]，@racket[-inf.0]和@racket[+nan.0]（或@racketvalfont{-nan.0}）；}
 @item{一个带有实部和虚部配对的复数的IEEE浮点表示，比如：@racket[2.0+3.0i]或@racket[-inf.0+nan.0i]；一种特殊情况是，一个不精确的复数可以有一个精确的零实部和一个不精确的虚部。}]}]

对一个小数点或指数的说明符进行不精确数字打印，对整数和分数进行精确数字打印。用同样的约定申请读入数值常数，但@litchar{#e}或@litchar{#i}可以前缀数值以解析一个精确的或不精确的数值。前缀@litchar{#b}、@litchar{#o}和@litchar{#x}指定二进制、八进制和十六进制数值的解释。

@examples[
 0.5
 (eval:alts @#,racketvalfont{#e0.5} 1/2)
 (eval:alts @#,racketvalfont{#x03BB} #x03BB)]

计算涉及到精确的数值产生不精确的结果，这样的情况对数据造成一种污染。注意，然而，Racket没有提供"不精确的布尔值"，所以对不精确的数字的比较分支计算却能产生精确的结果。@racket[exact->inexact]和@racket[inexact->exact]程序在两种类型的数值之间转换。

@examples[
(/ 1 2)
(/ 1 2.0)
(if (= 3.0 2.999) 1 2)
(inexact->exact 0.1)]

当精确的结果需要表达实际的非有理数数值，不精确的结果也由像@racket[sqrt]、@racket[log]和@racket[sin]这样的程序产生。Racket只能代表有理数和有理数配对的复数。

@examples[
(code:line (sin 0)
           (code:comment @#,t{有理数...}))

(code:line (sin 1/2)
           (code:comment @#,t{非有理数...}))]

在性能方面，小整数的计算通常是最快的，其中“小”意味着这个数字比有符号数值的机器字长要小一点。具有非常大的精确整数或非整精确数的计算要比不精确数的计算代价要高昂得多。

@def+int[
(define (sigma f a b)
  (if (= a b)
      0
      (+ (f a) (sigma f (+ a 1) b))))

(time (round (sigma (lambda (x) (/ 1 x)) 1 2000)))
(time (round (sigma (lambda (x) (/ 1.0 x)) 1 2000)))]

在针对通常的@racket[number?]的加法中，@deftech{整数类（integer）}、@deftech{有理数类（rational）}、@deftech{实类（real）}（总是有理数）和复数都以通常的方式定义，并被程序 @racket[integer?]、@racket[rational?]、@racket[real?]和@racket[complex?]所识别。一些数学过程只接受实数，但大多数实现了对复数的标准扩展。

@examples[
(integer? 5)
(complex? 5)
(integer? 5.0)
(integer? 1+2i)
(complex? 1+2i)
(complex? 1.0+2.0i)
(abs -5)
(abs -5+2i)
(sin -5+2i)]

@racket[=]过程比较数值相等的数值。如果给定不精确和精确的数字进行比较，它实际上会在比较之前将不精确数字转换为精确数字。@racket[eqv?]（乃至 @racket[equal?]）程序，相反，程序比较既是精确数而且数值上相等的数值。

@examples[
(= 1 1.0)
(eqv? 1 1.0)]

当心涉及不精确的数字比较，由于其性质会有令人惊讶的行为。即使是简单的不精确的数字也许并不意味着你能想到他们的意思；例如，当一个二进制IEEE浮点数可以表示为@racket[1/2]精确数，它只能近似于@racket[1/10]：

@examples[
(= 1/2 0.5)
(= 1/10 0.1)
(inexact->exact 0.1)]