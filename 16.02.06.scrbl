;16.02.06.scrbl
;16.2.6 通用阶段等级
#lang scribble/manual
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt"
          (for-label syntax/parse))

@title[#:tag "phases"]{通用阶段等级}

一个@deftech{阶段（phase）}可以被看作是在一个进程的管道中分离出计算的方法，在这个过程中，一个代码生成下一个程序所使用的代码。（例如，由预处理器进程、编译器和汇编程序组成的管道）。

设想为此启动两个Racket过程。如果忽略套接字和文件之类的进程间通信通道，则进程将无法共享任何其它内容，而不是从一个进程的标准输出导入到另一个进程的标准输入中的文本。同样，Racket有效地允许一个模块的多个调用在同一进程中存在但相隔阶段。Racket强制@emph{分离}这些阶段，不同的阶段不能以任何方式进行通信，除非通过宏扩展协议，其中一个阶段的输出是下一阶段使用的代码。

@; 16.2.6.1 阶段和绑定----------------------------------------------------------
@section[#:tag "Phases-and-Bindings"]{阶段和绑定}

一个标识符的每个绑定都存在于特定的阶段中。一个绑定和它的阶段之间的链接用整数@deftech{阶段等级（phase level）}表示。阶段等级0是用于“扁平”（或“运行时”）定义的阶段，因此

@racketblock[
(define age 5)
]

为@racket[age]添加绑定到阶段等级0中。标识符@racket[age]可以在较高的阶段等级上用@racket[begin-for-syntax]定义：

@racketblock[
(begin-for-syntax
  (define age 5))
]

对一个单一的@racket[begin-for-syntax]包装器，@racket[age]被定义在阶段等级1。我们可以容易地在同一个模块或顶级命名空间中混合这两个定义，并且在不同的阶段等级上定义的两个@racket[age]之间没有冲突：

@(define age-eval (make-base-eval))
@(interaction-eval #:eval age-eval (require (for-syntax racket/base)))

@interaction[#:eval age-eval
(define age 3)
(begin-for-syntax
  (define age 9))
]

在阶段等级0的@racket[age]绑定有一个值为3，在阶段等级1的@racket[age]绑定有一个值为9。

语法对象将绑定信息捕获为一级值。因此，

@racketblock[#'age]

是一个表示@racket[age]绑定的语法对象，但因为有两个@racket[age]（一个在阶段等级0，一个在阶段等级1），哪一个是它捕获的？事实上，Racket用给所有阶段等级的词汇信息充满@racket[#'age]，所以答案是@racket[#'age]捕捉两者。

当@racket[#'age]被最终使用时，被@racket[#'age]捕获的@racket[age]的相关的绑定被决定。作为一个例子，我们将@racket[#'age]绑定到模式变量，所以我们可以在一个模板里使用它，并对模板求值@racket[eval]：

@interaction[#:eval age-eval
(eval (with-syntax ([age #'age])
        #'(displayln age)))
]

结果是@racket[3]，因为@racket[age]在第0阶段等级使用。我们可以在@racket[begin-for-syntax]内再试一次@racket[age]的使用：

@interaction[#:eval age-eval
(eval (with-syntax ([age #'age])
        #'(begin-for-syntax
            (displayln age))))
]

在这种情况下，答案是@racket[9]，因为我们使用的@racket[age]是阶段等级1而不是0（即， @racket[begin-for-syntax]在阶段等级1求值表达式）。所以，你可以看到，我们用相同的语法对象开始，@racket[#'age]，并且我们能够使用这两种不同的方法：在阶段等级0和在阶段等级1。

语法对象有一个词法上下文，从它第一次存在的时刻起。从模块中提供的语法对象保留其词法上下文，因此它引用源模块上下文中的绑定，而不是其使用上下文中的。下面的示例在第0阶段等级定义了@racket[button]，并将其绑定到@racket[0]，同时@racket[see-button]为在模块@racket[a]中的@racket[button]绑定语法对象：

@interaction[
(module a racket
  (define button 0)
  (provide (for-syntax see-button))
  @code:comment[@#,t{Why not @racket[(define see-button #'button)]? We explain later.}]
  (define-for-syntax see-button #'button))

(module b racket
  (require 'a)
  (define button 8)
  (define-syntax (m stx)
    see-button)
  (m))

(require 'b)
]

在@racket[m]宏的结果是@racket[see-button]的值，它是带有模块@racket[a]的词汇上下文的@racket[#'button]。即使是在@racket[b]中的另一个@racket[button]，第二个@racket[button]不会混淆Racket，因为@racket[#'button]（这个值对@racket[see-button]予以绑定）的词汇上下文是@racket[a].

注意，@racket[see-button]是被用@racket[define-for-syntax]定义它的长处约束在第1阶段等级。由于@racket[m]是一个宏，所以需要第1阶段等级，所以它的本体在高于它的定义上下文的一个阶段执行。由于@racket[m]是在第0阶段等级定义的，所以它的本体处于阶段等级1，所以由本体引用的任何绑定都必须在阶段等级1上。

@; 16.2.6.2 阶段和模块------------------------------------------------
@section[#:tag "Phases-and-Modules"]{阶段和模块}

@tech{阶段等级（phase level）}是一个模块相关概念。当通过@racket[require]从另一个模块导入时，Racket允许我们将导入的绑定转移到与原来的绑定不同的阶段等级：

@racketblock[
(require "a.rkt")                @code:comment{不带阶段转移的导入}
(require (for-syntax "a.rkt"))   @code:comment{通过+1转移阶段}
(require (for-template "a.rkt")) @code:comment{通过-1转移阶段}
(require (for-meta 5 "a.rkt" ))  @code:comment{通过+5转移阶段}
]

也就是说，在@racket[require]中使用@racket[for-syntax]意味着该模块的所有绑定都会增加它们的阶段等级。在第0阶段等级@racket[define]（定义）并用@racket[for-syntax]导入的绑定成为一个阶段等级1的绑定：

@interaction[
(module c racket
  (define x 0) @code:comment{在0阶段等级定义}
  (provide x))

(module d racket
  (require (for-syntax 'c))
  @code:comment{在阶段等级1有一个绑定，不是0：}
  #'x)
]

让我们看看如果我们试图在阶段等级0创建一个给@racket[#'button]绑定的语法对象发生了什么：

@(define button-eval (make-base-eval))
@(interaction-eval #:eval button-eval
                   (require (for-syntax racket/base)))
@interaction[#:eval button-eval
(define button 0)
(define see-button #'button)
]

现在@racket[button]和@racket[see-button]在第0阶段等级中定义。对@racket[#'button]的词汇上下文会知道在阶段等级0有一个为@racket[button]的绑定。事实上，好像如果我们试图对@racket[see-button]进行@racket[eval]，一切都很好地运行：

@interaction[#:eval button-eval
(eval see-button)
]

现在，让我们在一个宏中使用@racket[see-button]：

@interaction[#:eval button-eval
(define-syntax (m stx)
  see-button)
(m)
]

显然，@racket[see-button]没有在阶段1级被定义，所以我们不能在宏本体内引用它。让我们在另一个模块中使用@racket[see-button]，通过将button定义放到一个模块中并在第1阶段等级导入它。那么，我们在第1阶段等级得到了@racket[see-button]：

@interaction[
(module a racket
  (define button 0)
  (define see-button #'button)
  (provide see-button))

(module b racket
  (require (for-syntax 'a)) @code:comment[@#,t{在阶段等级1取得@racket[see-button]}]
  (define-syntax (m stx)
    see-button)
  (m))
]

Racket说@racket[button]现在不受约束！当@racket[a]在阶段等级1被导入，我们有了以下的绑定：

@racketblock[
button     @#,elem{在阶段等级1}
see-button @#,elem{在阶段等级11}
]

所以宏@racket[m]能够看到一个在阶段等级1为@racket[see-button]的绑定并且将返回@racket[#'button]语法对象，它指的是在阶段等级1的@racket[button]绑定。但是@racket[m]的使用是在第0阶段等级，在@racket[b]的第0阶段等级没有@racket[button]。这就是为什么@racket[see-button]需要约束在第1阶段等级，就像在原来的@racket[a]中。那么，在原来的@racket[b]中，我们有以下绑定：

@racketblock[
button     @#,elem{在阶段等级0}
see-button @#,elem{在阶段等级1}
]

在这个场景中，我们可以在宏中使用@racket[see-button]，因为在阶段等级1上@racket[see-button]是绑定的。当宏展开时，它将指向一个在第0阶段等级的@racket[button]绑定。

用@racket[(define see-button
#'button)]定@racket[see-button]本身没有错；它取决于我们打算如何使用@racket[see-button]。例如，我们可以安排@racket[m]明智地使用@racket[see-button]，因为它使用@racket[begin-for-syntax]将它放在了阶段等级1的上下文中：

@interaction[
(module a racket
  (define button 0)
  (define see-button #'button)
  (provide see-button))

(module b racket
  (require (for-syntax 'a))
  (define-syntax (m stx)
    (with-syntax ([x see-button])
      #'(begin-for-syntax
          (displayln x))))
  (m))
]

在这种情况下，模块@racket[b]在阶段等级1上机有@racket[button]绑定也有@racket[see-button]绑定。宏的扩展是

@racketblock[
(begin-for-syntax
  (displayln button))
]

它的工作原理是，因为@racket[button]在阶段等级1上绑定。

现在，你可以通过在阶段等级0和阶段等级1中导入@racket[a]来欺骗阶段系统。然后，你将具有以下绑定

@racketblock[
button     @#,elem{在阶段等级0}
see-button @#,elem{在阶段等级0}
button     @#,elem{在阶段等级1}
see-button @#,elem{在阶段等级1}
]

你可能现在希望宏中的@racket[see-button]可以工作，但它没有：

@interaction[
(module a racket
  (define button 0)
  (define see-button #'button)
  (provide see-button))

(module b racket
  (require 'a
           (for-syntax 'a))
  (define-syntax (m stx)
    see-button)
  (m))
]

宏@racket[m]中的@racket[see-button]来自于@racket[(for-syntax 'a)]的导入。为了让宏@racket[m]运行，它需要在第0阶段有@racket[button]绑定。那个绑定存在——它通过@racket[(require 'a)]表明。然而，@racket[(require 'a)]和@racket[(require (for-syntax 'a))]是相同模块的@emph{不同实例（different instantiation）}。第1阶段的@racket[see-button]按钮仅指第1阶段的@racket[button]，而不是来自一个不同实例的第0阶段绑定的@racket[button]，即使来自同一个源模块。

这种阶段等级之间的不匹配的实例可以用@racket[syntax-shift-phase-level]修复。像@racket[#'button]捕捉词汇信息那样在@emph{所有（all）}阶段等级重调用语法对象。这里的问题是@racket[see-button]在第1阶段调用，但需要返回一个可以在第0阶段进行求值的语法对象。默认情况下，@racket[see-button]在同一阶段绑定到@racket[#'button]。但通过@racket[syntax-shift-phase-level]，我们可以使see-button在不同的相对阶段等级适用于#'button。在这种情况下，我们使用一个-1的阶段转移使在阶段1的@racket[see-button]适用于在0阶段的@racket[#'button]。（由于阶段转变发生在每一个等级，它也使0阶段的@racket[see-button]适用于-1阶段的@racket[#'button]）

注意，@racket[syntax-shift-phase-level]只创建跨阶段的引用。为了使该引用运行，我们仍然需要在两个阶段实例化我们的模块，以便引用和它的目标具有可用的绑定。因此，在模块@racket['b]，我们仍然在阶段0和阶段1导入模块@racket['a]——使用@racket[(require 'a (for-syntax 'a))]——因此我们为@racket[see-button]的阶段1绑定和为@racket[button]的一个阶段0绑定。现在宏@racket[m]就会运行了。

@interaction[
(module a racket
  (define button 0)
  (define see-button (syntax-shift-phase-level #'button -1))
  (provide see-button))

(module b racket
  (require 'a (for-syntax 'a))
  (define-syntax (m stx)
    see-button)
  (m))

(require 'b)
]

顺便问一下，在第0阶段绑定的@racket[see-button]会发生什么？其#'button绑定也已经转移，但是对阶段-1。由于@racket[button]本身在-1阶段不受约束，如果我们试图在第0阶段对@racket[see-button]求值，我们会得到一个错误。换句话说，我们并没有永久地解决我们的不匹配问题——我们只是把它转移到一个不太麻烦的位置。

@interaction[
(module a racket
  (define button 0)
  (define see-button (syntax-shift-phase-level #'button -1))
  (provide see-button))

(module b racket
  (require 'a (for-syntax 'a))
  (define-syntax (m stx)
    see-button)
  (m))

(module b2 racket
  (require 'a)
  (eval see-button))

(require 'b2)
]

当宏试图匹配字面绑定时——使用@racket[syntax-case]或@racket[syntax-parse]，也可能出现上述不匹配的错误。

@interaction[
(module x racket
  (require (for-syntax syntax/parse)
           (for-template racket/base))

  (provide (all-defined-out))

  (define button 0)
  (define (make) #'button)
  (define-syntax (process stx)
    (define-literal-set locals (button))
    (syntax-parse stx
      [(_ (n (~literal button))) #'#''ok])))

(module y racket
  (require (for-meta 1 'x)
           (for-meta 2 'x racket/base))

  (begin-for-syntax
    (define-syntax (m stx)
      (with-syntax ([out (make)])
        #'(process (0 out)))))

  (define-syntax (p stx)
    (m))

  (p))
]

在这个例子中，在阶段等级2里@racket[make]正在@racket[y]中被使用，它返回的@racket[#'button]语法对象——指的是@racket[button]在阶段0的@racket[x]里的绑定和在阶段等级2的来自@racket[(for-meta 2 'x)]的@racket[y]里的绑定。@racket[process]宏在阶段等级1从@racket[(for-meta 1 'x)]导入，并且它知道@racket[button]应该在阶段等级1上绑定。当@racket[syntax-parse]在@racket[process]内执行时，它正在寻找在阶段等级1上绑定的@racket[button]，但它仅看到一个阶段等级2绑定并且不匹配。

为了修正这个例子，我们可以相对于x在阶段等级1提供@racket[make]，然后在@racket[y]中的第1阶段等级导入它：

@interaction[
(module x racket
  (require (for-syntax syntax/parse)
           (for-template racket/base))

  (provide (all-defined-out))

  (define button 0)

  (provide (for-syntax make))
  (define-for-syntax (make) #'button)
  (define-syntax (process stx)
    (define-literal-set locals (button))
    (syntax-parse stx
      [(_ (n (~literal button))) #'#''ok])))

(module y racket
  (require (for-meta 1 'x)
           (for-meta 2 racket/base))

  (begin-for-syntax
    (define-syntax (m stx)
      (with-syntax ([out (make)])
        #'(process (0 out)))))

  (define-syntax (p stx)
    (m))

  (p))

(require 'y)
]

@;--------------------------------------------------
@(close-eval age-eval)
@(close-eval button-eval)