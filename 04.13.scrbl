;04.13.scrbl
;4.13 动态绑定：parameterize
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@(define param-eval (make-base-eval))

@title[#:tag "parameterize"]{动态绑定：@racket[parameterize]}

@racket[parameterize]表把一个新值和@racket[_body]表达式求值过程中的一个参数@deftech{parameter}相结合：

@specform[(parameterize ([parameter-expr value-expr] ...)
            body ...+)]

例如，@racket[error-print-width]参数控制在错误消息中打印一个值的字符数：

@interaction[
(parameterize ([error-print-width 5])
  (car (expt 10 1024)))
(parameterize ([error-print-width 10])
  (car (expt 10 1024)))
]
  
一般来说，参数实现了一种动态绑定。@racket[make-parameter]函数接受任何值并返回一个初始化为给定值的新参数。应用参数作为一个函数返回它的其当前值：

@interaction[
#:eval param-eval
(define location (make-parameter "here"))
(location)
]

在一个@racket[parameterize]表里，每个@racket[_parameter-expr]必须产生一个参数。在对@racket[body]求值过程中，每一个指定的参数给出对应于@racket[_value-expr]的结果。当控制离开@racket[parameterize]表——无论是通过正常的返回，一个例外，或其它逃避——参数恢复到其先前的值：

@interaction[
#:eval param-eval
(parameterize ([location "there"])
  (location))
(location)
(parameterize ([location "in a house"])
  (list (location)
        (parameterize ([location "with a mouse"])
          (location))
        (location)))
(parameterize ([location "in a box"])
  (car (location)))
(location)
]

@racket[parameterize]表不是一个像@racket[let]那样的绑定表；每次@racket[location]的使用向上都直接指向原来的定义。在@racket[parameterize]主体被求值的整个时间内@racket[parameterize]表调整参数的值，甚至是文本以外的@racket[parameterize]主体的参数使用：

@interaction[
#:eval param-eval
(define (would-you-could-you?)
  (and (not (equal? (location) "here"))
       (not (equal? (location) "there"))))

(would-you-could-you?)
(parameterize ([location "on a bus"])
  (would-you-could-you?))
]

如果参数的使用是在一个@racket[parameterize]主体内部进行的，但是在@racket[parameterize]表产生一个值之前没有被求值，那么这个用法看不到@racket[parameterize]表所安装的值：

@interaction[
#:eval param-eval
(let ([get (parameterize ([location "with a fox"])
             (lambda () (location)))])
  (get))
]

参数的当前绑定可以通过将该参数作为具有值的函数进行调用以进行必要的调整。 如果@racket[parameterize]已经调整了参数的值，那么直接应用参数过程只会影响与活动@racket[parameterize]相关的值：

@interaction[
#:eval param-eval
(define (try-again! where)
  (location where))

(location)
(parameterize ([location "on a train"])
  (list (location)
        (begin (try-again! "in a boat")
               (location))))
(location)
]

使用@racket[parameterize]通常更适合于更新参数值，这与使用@racket[let]绑定新变量的原因相同，最好使用@racket[set!] （见《赋值：set!》（@secref["set!"]））。

似乎变量和@racket[set!]可以解决很多参数解决的相同问题。 例如，@racket[lokation]可以被定义为一个字符串，以及@racket[set!]可以用来调整它的价值：

@interaction[
#:eval param-eval
(define lokation "here")

(define (would-ya-could-ya?)
  (and (not (equal? lokation "here"))
       (not (equal? lokation "there"))))

(set! lokation "on a bus")
(would-ya-could-ya?)
]

然而，参数与@racket[set!]相比，参数提供了几个关键的优点：

@itemlist[

 @item{@racket[parameterize]表有助于在正确避免异常时自动重置参数的值。 添加异常处理程序和其它表去实现转回一个@racket[set!]是比较繁琐的。}

 @item{参数可以和尾（tail）调用很好的一致（请参阅《尾递归》(@secref["tail-recursion"])）。@racket[parameterize]表中的最后一个@racket[_body]相对于@racket[parameterize]表处于尾部位置。}

@item{参数与线程正常工作（请参阅《线程》（@refsecref["threads"]））。 @racket[parameterize]表仅调整当前线程中的参数值，以避免与其他线程竞争。}
]

@; ----------------------------------------
@close-eval[param-eval]