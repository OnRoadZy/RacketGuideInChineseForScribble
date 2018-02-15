;04.02.scrbl
;4.2 标识符和绑定
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "binding"]{标识符和绑定}

表达式的上下文决定表达式中出现的标识符的含义。特别是，用语言@racketmodname[racket]开始一个模块时，如：

@racketmod[racket]

意味着，在模块中，本指南中描述的标识符从这里描述的含义开始：@racket[cons]指创建一个配对的函数，@racket[car]指的是提取一个配对的第一个元素的函数，等等。

诸如@racket[define]、@racket[lambda]和@racket[let]的表，并让一个意义与一个或多个标识符相关联，也就是说，它们@defterm{绑定（bind）}标识符。绑定应用的程序的一部分是绑定的@defterm{范围（scope）}。对给定表达式有效的绑定集是表达式的@defterm{环境（environment）}。

例如，有以下内容：

@racketmod[
racket

(define f
  (lambda (x)
    (let ([y 5])
      (+ x y))))

(f 10)
]

@racket[define]是@racket[f]的绑定，@racket[lambda]有一个对@racket[x]的绑定，@racket[let]有一个对@racket[y]的绑定，对@racket[f]的绑定范围是整个模块；@racket[x]绑定的范围是@racket[(let ([y 5]) (+
x y))]；@racket[y]绑定的范围仅仅是@racket[(+ x
y)]的环境包括对@racket[y]、@racket[x]和@racket[f]的绑定，以及所有在@racketmodname[racket]中的绑定。

模块级的@racket[define]只能绑定尚未定义或被@racket[require]进入模块的标识符。但是，局部@racket[define]或其它绑定表可以为已有绑定的标识符提供新的局部绑定；这样的绑定会对现有绑定屏蔽（@deftech{shadows}）。

@defexamples[
(define f
  (lambda (append)
    (define cons (append "ugly" "confusing"))
    (let ([append 'this-was])
      (list append cons))))
(f list)
]

类似地，模块级@racket[define]可以从模块的语言中@tech{屏蔽（shadow）}一个绑定。例如，一个@racketmodname[racket]模块里的@racket[(define cons 1)]屏蔽被@racketmodname[racket]所提供的@racket[cons]。有意屏蔽一个语言绑定是一个绝佳的主意——尤其是像@racket[cons]这种被广泛使用的绑定——但是屏蔽消除了程序员应该避免使用的语言提供的所有模糊绑定。

即使像@racket[define]和@racket[lambda]这些从绑定中得到它们的含义，尽管它们有@defterm{转换（transformer）}绑定（这意味着它们表示语法表）而不是值绑定。由于@racketidfont{define}具有一个转换绑定，因此标识符本身不能用于获取值。但是，对@racketidfont{define}的常规绑定可以被屏蔽。

@examples[
define
(eval:alts (let ([@#,racketidfont{define} 5]) @#,racketidfont{define}) (let ([define 5]) define))
]

同样，用这种方式来隐藏标准绑定是一个绝佳主意，但这种可能性是Racket灵活性的与生俱来的部分。