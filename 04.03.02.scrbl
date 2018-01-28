;04.03.02.scrbl
;4.3.2 关键字参数
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{关键字参数}

除了通过位置参数外，有些函数接受@defterm{关键字参数（keyword arguments）}。因此，@racket[_arg]可以是一个@racket[_arg-keyword _arg-expr]序列而不只是一个@racket[_arg-expr]：

@specform/subs[
(_proc-expr arg ...)
([arg arg-expr
      (code:line arg-keyword arg-expr)])
]

例如：

@racketblock[(go "super.rkt" #:mode 'fast)]

用@racket["super.rkt"]调用函数绑定到 @racket[go] 作为位置参数，并用@racket['fast]通过@racket[#:mode]关键字作为相关参数。关键字隐式地与后面的表达式配对。

既然关键字本身不是一个表达式，那么

@racketblock[(go "super.rkt" #:mode #:fast)]

就是语法错误。@racket[#:mode]关键字必须跟着一个表达式以产生一个参数值，并@racket[#:fast]不是一个表达式。

关键字@racket[_arg]的顺序决定@racket[_arg-expr]的求值顺序，而一个函数接受关键字参数与在参数列表中的位置无关。上面对@racket[go]的调用可以等价地写为：

@racketblock[(go #:mode 'fast "super.rkt")]