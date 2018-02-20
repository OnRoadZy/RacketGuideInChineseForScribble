;14.scrbl
;14 单元（组件）
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt"
          (for-label racket/unit
                     racket/class))

@(define toy-eval (make-base-eval))

@(interaction-eval #:eval toy-eval (require racket/unit))

@(define-syntax-rule (racketmod/eval [pre ...] form more ...)
   (begin
     (racketmod pre ... form more ...)
     (interaction-eval #:eval toy-eval form)))

@title[#:tag "units" #:style 'toc]{单元@aux-elem{ (组件)}}

@deftech{单元（unit）}组织程序分成独立的编译和可重用的@deftech{组件（component）}。一个单元类似于过程，因为这两个都是用于抽象的一级值。虽然程序对表达式中的值进行抽象，但在集合定义中对名称进行抽象。正如一个过程被调用来对它的表达式求值，表达式把实际的参数作为给它的正式参数，一个单元被@deftech{调用（invoked）}来对它的定义求值，这个定义给出其导入变量的实际引用。但是，与过程不同的是，在调用之前，一个单元的导入变量可以部分地与另一个@italic{之前调用（prior to
invocation）}单元的导出变量链接。链接将多个单元合并成单个复合单元。复合单元本身导入将传播到链接单元中未解决的导入变量的变量，并从链接单元中重新导出一些变量以进一步链接。

@;-------------------------------------------------------------
@local-table-of-contents[]

@; 14.1 签名和单元----------------------------------------
@section[#:tag "Signatures and Units"]{ 签名和单元}

单元的接口用@deftech{签名（signature）}来描述。每个签名都使用@racket[define-signature]来定义（通常在@racket[module]（模块）中）。例如，下面的签名，放在一个@filepath{toy-factory-sig.rkt}的文件中，描述了一个组件的导出（export），它实现了一个玩具厂（toy factory）：

@racketmod/eval[[#:file
"toy-factory-sig.rkt"
racket]

(define-signature toy-factory^
  (build-toys  (code:comment #, @tt{(integer? -> (listof toy?))})
   repaint     (code:comment #, @tt{(toy? symbol? -> toy?)})
   toy?        (code:comment #, @tt{(any/c -> boolean?)})
   toy-color)) (code:comment #, @tt{(toy? -> symbol?)})

(provide toy-factory^)
]

一个@racket[toy-factory^]签名的实现是用@racket[define-unit]来写的，它定义了一个名为@racket[toy-factory^]的@racket[export]（导出）从句：

@racketmod/eval[[#:file
"simple-factory-unit.rkt"
racket

(require "toy-factory-sig.rkt")]

(define-unit simple-factory@
  (import)
  (export toy-factory^)

  (printf "Factory started.\n")

  (define-struct toy (color) #:transparent)

  (define (build-toys n)
    (for/list ([i (in-range n)])
      (make-toy 'blue)))

  (define (repaint t col)
    (make-toy col)))

(provide simple-factory@)
]

@racket[toy-factory^]签名也可以被一个单元引用，它需要一个玩具工厂来实施其它某些东西。在这种情况下，@racket[toy-factory^]将以一个@racket[import]（导入）从句命名。例如，玩具店可以从玩具厂买到玩具。（假设为了一个有趣的例子，商店只愿意出售特定颜色的玩具）。

@racketmod/eval[[#:file
"toy-store-sig.rkt"
racket]

(define-signature toy-store^
  (store-color     (code:comment #, @tt{(-> symbol?)})
   stock!          (code:comment #, @tt{(integer? -> void?)})
   get-inventory)) (code:comment #, @tt{(-> (listof toy?))})

(provide toy-store^)
]

@racketmod/eval[[#:file
"toy-store-unit.rkt"
racket

(require "toy-store-sig.rkt"
         "toy-factory-sig.rkt")]

(define-unit toy-store@
  (import toy-factory^)
  (export toy-store^)

  (define inventory null)

  (define (store-color) 'green)

  (define (maybe-repaint t)
    (if (eq? (toy-color t) (store-color))
        t
        (repaint t (store-color))))

  (define (stock! n)
    (set! inventory 
          (append inventory
                  (map maybe-repaint
                       (build-toys n)))))

  (define (get-inventory) inventory))

(provide toy-store@)
]

请注意，@filepath{toy-store-unit.rkt}导入@filepath{toy-factory-sig.rkt}，而不是@filepath{simple-factory-unit.rkt}。因此，@racket[toy-store@]单元只依赖于玩具工厂的规格，而不是具体的实施。

@; 14.2 调用单元----------------------------------------
@section[#:tag "Invoking-Units"]{调用单元}

@racket[simple-factory@]单元没有导入，因此可以使用@racket[invoke-unit]直接调用它：

@interaction[
#:eval toy-eval
(eval:alts (require "simple-factory-unit.rkt") (void))
(invoke-unit simple-factory@)
]

但是，@racket[invoke-unit]表并不能使主体定义可用，因此我们不能在这家工厂制造任何玩具。@racket[define-values/invoke-unit]表将签名的标识符绑定到实现签名的一个单元（要@tech{调用}的）提供的值：

@interaction[
#:eval toy-eval
(define-values/invoke-unit/infer simple-factory@)
(build-toys 3)
]

由于@racket[simple-factory@]导出@racket[toy-factory^]签名，@racket[toy-factory^]的每个标识符都是由@racket[define-values/invoke-unit/infer]表定义的。表名称的@racketidfont{/infer}部分表明，由声明约束的标识符是从@racket[simple-factory@]推断出来的。

在定义@racket[toy-factory^]的标识后，我们还可以调用@racket[toy-store@]，它导入@racket[toy-factory^]以产生@racket[toy-store^]：

@interaction[
#:eval toy-eval
(eval:alts (require "toy-store-unit.rkt") (void))
(define-values/invoke-unit/infer toy-store@)
(get-inventory)
(stock! 2)
(get-inventory)
]

同样，@racketidfont{/infer}部分@racket[define-values/invoke-unit/infer]确定@racket[toy-store@]导入@racket[toy-factory^]，因此它提供与@racket[toy-factory^]中的名称匹配的顶级绑定，如导入@racket[toy-store@]。

@; 14.3 链接单元----------------------------------------
@section[#:tag "Linking-Units"]{链接单元}

我们可以借助玩具工厂的合作使我们的玩具店玩具经济性更有效，不需要重新创建。相反，玩具总是使用商店的颜色来制造，而工厂的颜色是通过导入@racket[toy-store^]来获得的：

@racketmod/eval[[#:file
"store-specific-factory-unit.rkt"
racket

(require "toy-store-sig.rkt"
         "toy-factory-sig.rkt")]

(define-unit store-specific-factory@
  (import toy-store^)
  (export toy-factory^)

  (define-struct toy () #:transparent)

  (define (toy-color t) (store-color))

  (define (build-toys n)
    (for/list ([i (in-range n)])
      (make-toy)))

  (define (repaint t col)
    (error "cannot repaint")))

(provide store-specific-factory@)
]

要调用@racket[store-specific-factory@]，我们需要@racket[toy-store^]绑定供及给单元。但是为了通过调用@racket[toy-store^]来获得@racket[toy-store^]的绑定，我们需要一个玩具工厂！单元实现是相互依赖的，我们不能在另一个之前调用那一个。

解决方案是将这些单元@deftech{链接（link）}在一起，然后调用组合单元。@racket[define-compound-unit/infer]表将任意数量的单元链接成一个组合单元。它可以从相连的单元中进行导入和导出，并利用其它链接单元的导出来满足各单元的导入。

@interaction[
#:eval toy-eval
(eval:alts (require "toy-factory-sig.rkt") (void))
(eval:alts (require "toy-store-sig.rkt") (void))
(eval:alts (require "store-specific-factory-unit.rkt") (void))
(define-compound-unit/infer toy-store+factory@
  (import)
  (export toy-factory^ toy-store^)
  (link store-specific-factory@
        toy-store@))
]

上边总的结果是一个单元@racket[toy-store+factory@]，其导出既是@racket[toy-factory^]也是@racket[toy-store^]。从每个导入和导出的签名中推断出@racket[store-specific-factory@]和@racket[toy-store@]之间的联系。

这个单元没有导入，所以我们可以随时调用它：

@interaction[
#:eval toy-eval
(define-values/invoke-unit/infer toy-store+factory@)
(stock! 2)
(get-inventory)
(map toy-color (get-inventory))
]

@; 14.4 一级单元----------------------------------------
@section[#:tag "firstclassunits"]{一级单元}

@racket[define-unit]表将@racket[define]与@racket[unit]表相结合，类似于@racket[(define (f x)
....)]结合@racket[define]，后跟带一个隐式的@racket[lambda]的标识符。

扩大简写，@racket[toy-store@]的定义几乎可以写成

@racketblock[
(define toy-store@
  (unit
   (import toy-factory^)
   (export toy-store^)

   (define inventory null)

   (define (store-color) 'green)
   ....))
]

这个扩展和@racket[define-unit]的区别在于，@racket[toy-store@]的导入和导出不能被推断出来。也就是说，除了将@racket[define]和@racket[unit]结合在一起，@racket[define-unit]还将静态信息附加到定义的标识符，以便静态地提供它的签名信息来@racket[define-values/invoke-unit/infer]和其它表。

虽有丢失静态签名信息的缺点，@racket[unit]可以与使用第一类值的其它表结合使用。例如，我们可以封装一个@racket[unit]，它在一个 @racket[lambda]中创建一个玩具商店来提供商店的颜色：

@racketmod/eval[[#:file
"toy-store-maker.rkt"
racket

(require "toy-store-sig.rkt"
         "toy-factory-sig.rkt")]

(define toy-store@-maker
  (lambda (the-color)
    (unit
     (import toy-factory^)
     (export toy-store^)

     (define inventory null)

     (define (store-color) the-color)

     (code:comment @#,t{the rest is the same as before})

     (define (maybe-repaint t)
       (if (eq? (toy-color t) (store-color))
           t
           (repaint t (store-color))))

     (define (stock! n)
       (set! inventory
             (append inventory
                     (map maybe-repaint
                          (build-toys n)))))

     (define (get-inventory) inventory))))

(provide toy-store@-maker)
]

要调用由@racket[toy-store@-maker]创建的单元，我们必须使用@racket[define-values/invoke-unit]，而不是@racketidfont{/infer}变量：

@interaction[
#:eval toy-eval
(eval:alts (require "simple-factory-unit.rkt") (void))
(define-values/invoke-unit/infer simple-factory@)
(eval:alts (require "toy-store-maker.rkt") (void))
(define-values/invoke-unit (toy-store@-maker 'purple)
  (import toy-factory^)
  (export toy-store^))
(stock! 2)
(get-inventory)
]

在@racket[define-values/invoke-unit]表中，@racket[(import
toy-factory^)]行从当前的上下文中获取与@racket[toy-factory^]中的名称匹配的绑定（我们通过调用@racket[simple-factory@])创建的名称），并将它们提供于导入@racket[toy-store@]。@racket[(export toy-store^)]从句表明@racket[toy-store@-maker]产生的单元将导出@racket[toy-store^]，并在调用该单元后定义该签名的名称。

为了把一个单元与@racket[toy-store@-maker]链接起来，我们可以使用@racket[compound-unit]表：

@interaction[
#:eval toy-eval
(eval:alts (require "store-specific-factory-unit.rkt") (void))
(define toy-store+factory@
  (compound-unit
   (import)
   (export TF TS)
   (link [((TF : toy-factory^)) store-specific-factory@ TS]
         [((TS : toy-store^)) toy-store@ TF])))
]

这个@racket[compound-unit]表将许多信息聚集到一个地方。@racket[link]从句中的左侧@racket[TF]和@racket[TS]是绑定标识符。标识符@racket[TF]基本上绑定到@racket[toy-factory^]的元素作为由@racket[store-specific-factory@]的实现。标识符@racket[TS]类似地绑定到@racket[toy-store^]的元素作为由@racket[toy-store@]的实现。同时，绑定到@racket[TS]的元素作为提供给@racket[store-specific-factory@]的导入，因为@racket[TS]是随着@racket[store-specific-factory@]的。绑定到@racket[TF]的元素也同样提供给@racket[toy-store^]。最后，@racket[(export TF TS)]表明绑定到@racket[TF]和@racket[TS]的元素从复合单元导出。

上面的@racket[compound-unit]表使用@racket[store-specific-factory@]作为一个一级单元，尽管它的信息可以推断。除了在推理上下文中的使用外，每个单元都可以用作一个一级单元。此外，各种表让程序员弥合了推断的和一级的世界之间的间隔。例如，@racket[define-unit-binding]将一个新的标识符绑定到由任意表达式生成的单元；它静态地将签名信息与标识符相关联，并动态地对表达式产生的一级单元进行签名检查。

@; 14.5 完整的-module签名和单元----------------------------------------
@section[#:tag "Whole-module-Signatures-and-Units"]{完整的@racket[module]签名和单元}

在程序中使用的单元，模块如@filepath{toy-factory-sig.rkt}和@filepath{simple-factory-unit.rkt}是常见的。@racket[racket/signature]和@racket[racket/unit]模块的名称可以作为语言来避免大量的样板模块、签名和单元申明文本。

例如，@filepath{toy-factory-sig.rkt}可以写为

@racketmod[
racket/signature

build-toys  (code:comment #, @tt{(integer? -> (listof toy?))})
repaint     (code:comment #, @tt{(toy? symbol? -> toy?)})
toy?        (code:comment #, @tt{(any/c -> boolean?)})
toy-color   (code:comment #, @tt{(toy? -> symbol?)})
]

签名@racket[toy-factory^]是自动从模块中提供的，它通过用@racketidfont{^}从文件名@filepath{toy-factory-sig.rkt}置换@filepath{-sig.rkt}后缀来推断。

同样，@filepath{simple-factory-unit.rkt}模块可以写为

@racketmod[
racket/unit

(require "toy-factory-sig.rkt")

(import)
(export toy-factory^)

(printf "Factory started.\n")

(define-struct toy (color) #:transparent)

(define (build-toys n)
  (for/list ([i (in-range n)])
    (make-toy 'blue)))

(define (repaint t col)
  (make-toy col))
]

单元@racket[simple-factory@]是自动从模块中提供，它通过用@racketidfont["@"]从文件名@filepath{simple-factory-unit.rkt}置换@filepath{-unit.rkt}后缀来推断。

@; 14.6 单元合约----------------------------------------
@(interaction-eval #:eval toy-eval (require racket/contract))

@section[#:tag "Contracts-for-Units"]{单元合约}

有两种用合约保护单元的方法。一种方法在编写新的签名时是有用的，另一种方法当一个单元必须符合已经存在的签名时就可以处理这种情况。

@; 14.6.1 给签名添加合约--------------------------------------------
@subsection[#:tag "Adding-Contracts-to-Units"]{给签名添加合约}

当合约添加到签名时，实现该签名的所有单元都受到这些合约的保护。@racket[toy-factory^]签名的以下版本添加了前面说明中写过的合约：

@racketmod/eval[[#:file
"contracted-toy-factory-sig.rkt"
racket]

(define-signature contracted-toy-factory^
  ((contracted
    [build-toys (-> integer? (listof toy?))]
    [repaint    (-> toy? symbol? toy?)]
    [toy?       (-> any/c boolean?)]
    [toy-color  (-> toy? symbol?)])))

(provide contracted-toy-factory^)]

现在我们采用以前实现的@racket[simple-factory@]，并实现@racket[toy-factory^]的这个版本来代替：

@racketmod/eval[[#:file
"contracted-simple-factory-unit.rkt"
racket

(require "contracted-toy-factory-sig.rkt")]

(define-unit contracted-simple-factory@
  (import)
  (export contracted-toy-factory^)

  (printf "Factory started.\n")

  (define-struct toy (color) #:transparent)

  (define (build-toys n)
    (for/list ([i (in-range n)])
      (make-toy 'blue)))

  (define (repaint t col)
    (make-toy col)))

(provide contracted-simple-factory@)
]

和以前一样，我们可以调用我们的新单元并绑定导出，这样我们就可以使用它们。然而这次，滥用导出引起相应的合约错误。

@interaction[
#:eval toy-eval
(eval:alts (require "contracted-simple-factory-unit.rkt") (void))
(define-values/invoke-unit/infer contracted-simple-factory@)
(build-toys 3)
(build-toys #f)
(repaint 3 'blue)
]

@; 14.6.2 给单元添加合约---------------------------------------------------
@subsection[#:tag "Adding-Contracts-to-Units"]{给单元添加合约}

然而，有时我们可能有一个单元，它必须符合一个已经存在的签名而不是符合合约。在这种情况下，我们可以创建一个带@racket[unit/c]或使用@racket[define-unit/contract]表的单元合约，它定义了一个已被单元合约包装的单元。

例如，这里有一个@racket[toy-factory@]的版本，它仍然实现了规则@racket[toy-factory^]，但它的输出得到了适当的合约的保护。

@racketmod/eval[[#:file
"wrapped-simple-factory-unit.rkt"
racket

(require "toy-factory-sig.rkt")]

(define-unit/contract wrapped-simple-factory@
  (import)
  (export (toy-factory^
           [build-toys (-> integer? (listof toy?))]
           [repaint    (-> toy? symbol? toy?)]
           [toy?       (-> any/c boolean?)]
           [toy-color  (-> toy? symbol?)]))

  (printf "Factory started.\n")

  (define-struct toy (color) #:transparent)

  (define (build-toys n)
    (for/list ([i (in-range n)])
      (make-toy 'blue)))

  (define (repaint t col)
    (make-toy col)))

(provide wrapped-simple-factory@)
]

@interaction[
#:eval toy-eval
(eval:alts (require "wrapped-simple-factory-unit.rkt") (void))
(define-values/invoke-unit/infer wrapped-simple-factory@)
(build-toys 3)
(build-toys #f)
(repaint 3 'blue)
]

@; 14.7 unit（单元）与module（模块）的比较----------------------------------------
@section[#:tag "unit-versus-module"]{@racket[unit]（单元）与@racket[module]（模块）的比较}

作为模块的一个表，@racket[unit]（单元）是对@racket[module]（模块）的补充：

@itemize[

@item{@racket[module]表主要用于管理通用命名空间。例如，它允许一个代码片段是专指来自@racketmodname[racket/base]的@racket[car]运算——其中一个提取内置配对数据类型的一个实例的第一个元素——而不是任何其它带@racket[car]名字的函数。换句话说，@racket[module]构造允许你引用你想要的@emph{这个}绑定。}

 @item{@racket[unit]表是参数化的带相对于大多数运行时的值的任意种类的代码片段。例如，它允许一个代码片段与一个接受单个参数的@racket[car]函数一起工作，其中特定函数在稍后通过将片段连接到另一个参数被确定。换句话说，@racket[unit]结构允许你引用满足某些规范的一个绑定。}

]

除其他外，@racket[lambda]和@racket[class]表还允许对稍后选择的值进行代码参数化。原则上，其中任何一项都可以以其他任何方式执行。在实践中，每个表都提供了某些便利——例如允许重写方法或者特别是对值的特别简单的应用——使它们适合不同的目的。

从某种意义上说，@racket[module]表比其它表更为基础。毕竟，没有@racket[module]提供的命名空间管理，程序片段不能可靠地引用@racket[lambda]、@racket[class]或@racket[unit]表。同时，由于名称空间管理与单独的扩展和编译密切相关，@racket[module]边界以独立的编译边界结束，在某种程度上阻止了片段之间的相互依赖关系。出于类似的原因，@racket[module]不将接口与实现分开。

使用@racket[unit]的情况为，在@racket[module]本身几乎可以运行时，但当独立编译的部分必须相互引用时，或当你想要在@defterm{接口（interface）}（即，需要在扩展和编译时间被知道的部分）和@defterm{实现（implementation）}（即，运行时部分）之间有一个更强健的隔离时。更普遍使用@racket[unit]的情况是，当你需要在函数、数据类型和类上参数化代码时，以及当参数代码本身提供定义以和其它参数代码链接时。

@; ----------------------------------------------------------------------
@close-eval[toy-eval]