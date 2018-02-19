;15.scrbl
;15 反射和动态求值
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          racket/class
          "guide-utils.rkt")

@title[#:tag "reflection" #:style 'toc]{反射和动态求值}

Racket是一个动态的语言。它提供了许多用于加载、编译、甚至在运行时构造新代码的工具。

@;------------------------------------------
@local-table-of-contents[]

@; 15.1 eval----------------------------------------------------------------------
@section[#:tag "eval"]{@racket[eval]}

@racket[eval]函数构成一个表达或定义的表达（如“引用（quoted）”表或@tech{句法对象（syntax object）}）并且对它进行求值：

@interaction[
(eval '(+ 1 2))
]

@racket[eval]函数的强大在于表达式可以动态构造：

@interaction[
(define (eval-formula formula)
  (eval `(let ([x 2]
               [y 3])
           ,formula)))
(eval-formula '(+ x y))
(eval-formula '(+ (* x y) y))
]

当然，如果我们只是想计算表达式给出@racket[x]和@racket[y]的值，我们不需要@racket[eval]。更直接的方法是使用一级函数：

@interaction[
(define (apply-formula formula-proc)
  (formula-proc 2 3))
(apply-formula (lambda (x y) (+ x y)))
(apply-formula (lambda (x y) (+ (* x y) y)))
]

然而，譬如，如果表达式样@racket[(+ x y)]和@racket[(+ (* x y)
y)]是从用户提供的文件中读取，然后@racket[eval]可能是适当的。同样地，@tech{REPL}读取表达式，由用户输入，使用@racket[eval]求值。

一样地，在整个模块中@racket[eval]往往直接或间接地使用。例如，程序可以在定义域中用@racket[dynamic-require]读取一个模块，这基本上是一个封装在@racket[eval]中的动态加载模块的代码。

@; 15.1.1 本地域---------------------------------------------
@subsection{本地域}

@racket[eval]函数不能看到上下文中被调用的局部绑定。例如，调用在一个非引用的@racket[let]表中的@racket[eval]以对一个公式求值不会使得值@racket[x]和@racket[y]可见：

@interaction[
(define (broken-eval-formula formula)
  (let ([x 2]
        [y 3])
    (eval formula)))
(broken-eval-formula '(+ x y))
]

@racket[eval]函数不能看到@racket[x]和@racket[y]的绑定，正是因为它是一个函数，并且Racket是词法作用域的语言。想象一下如果@racket[eval]被实现为

@racketblock[
(define (eval x)
  (eval-expanded (macro-expand x)))
]

那么在@racket[eval-expanded]被调用的这个点上，@racket[x]最近的绑定是表达式求值，不是@racket[broken-eval-formula]中的@racket[let]绑定。词法范围防止这样的困惑和脆弱的行为，从而防止@racket[eval]表看到上下文中被调用的局部绑定。

你可以想象，即使通过@racket[eval]不能看到@racket[broken-eval-formula]中的局部绑定，这里实际上必须是一个@racket[x]到@racket[2]和@racket[y]到@racket[3]的数据结构映射，以及你想办法得到那些数据结构。事实上，没有这样的数据结构存在；编译器可以自由地在编译时替换带有@racket[2]的@racket[x]的每一个使用，因此在运行时的任何具体意义上都不存在@racket[x]的局部绑定。即使变量不能通过常量折叠消除，通常也可以消除变量的名称，而保存局部值的数据结构与从名称到值的映射不一样。

@; 15.1.2 命名空间（Namespace）---------------------------------------------------------
@subsection[#:tag "namespaces"]{命名空间（Namespace）}

由于@racket[eval]不能从它调用的上下文中看到绑定，另一种机制是需要确定动态可获得的绑定。一个@deftech{命名空间（namespace）}是一个一级的值，它封装了用于动态求值的可获得绑定。

某些函数，如@racket[eval]，接受一个可选的命名空间参数。通常，动态操作所使用的命名空间是@racket[current-namespace]@tech{参数}所确定的@deftech{当前命名空间（current namespace）}。

当@racket[eval]在@tech{REPL}中使用时，当前命名空间是@tech{REPL}使用于求值表达式中的一个。这就是为什么下面的互动设计成功通过@racket[eval]访问@racket[x]的原因：

@interaction[
(define x 3)
(eval 'x)
]

相反，尝试以下简单的模块并直接在DrRacket里或提供文件作为命令行参数给@exec{racket}运行它：

@racketmod[
racket

(eval '(cons 1 2))
]

这失败是因为初始当前命名空间是空的。当你在交互模式下运行@exec{racket}（见《@secref["start-interactive-mode"]》）时，初始的命名空间是用@racket[racket]模块的导出初始化的，但是当你直接运行一个模块时，初始的命名空间开始为空。

在一般情况下，用任何命名空间安装结果来使用@racket[eval]一个坏主意。相反，明确地创建一个命名空间并安装它以调用eval：

@racketmod[
racket

(define ns (make-base-namespace))
(eval '(cons 1 2) ns) (code:comment @#,t{运行})
]

 @racket[make-base-namespace]函数创建一个命名空间，该命名空间是用@racket[racket/base]导出初始化的。后一部分《@secref["mk-namespace"]》提供了关于创建和配置名称空间的更多信息。

@; 15.1.3 命名空间和模块--------------------------------------------------------
@subsection{命名空间和模块}

为@racket[let]绑定，词法范围意味着@racket[eval]不能自动看到一个调用它的@racket[module]（模块）的定义。然而，和@racket[let]绑定不同的是，Racket提供了一种将模块反射到一个@tech{namespace（命名空间）}的方法。

@racket[module->namespace]函数接受一个引用的@tech{模块路径（module path）}，并生成一个命名空间，用于对表达式和定义求值，就像它们出现在@racket[module]主体中一样：
 
@interaction[
(module m racket/base
  (define x 11))
(require 'm)
(define ns (module->namespace ''m))
(eval 'x ns)
]

@racket[module->namespace]函数对来自于模块之外的模块是最有用的，在这里模块的全名是已知的。然而，在@racket[module]表内，模块的全名可能不知道，因为它可能取决于在最终加载时模块源位于何处。

在@racket[module]内，使用@racket[define-namespace-anchor]声明模块上的反射钩子，并使用@racket[namespace-anchor->namespace]在模块的命名空间中滚动：

@racketmod[
racket

(define-namespace-anchor a)
(define ns (namespace-anchor->namespace a))

(define x 1)
(define y 2)

(eval '(cons x y) ns) (code:comment @#,t{produces @racketresult[(1 . 2)]})
]

@; 15.2 操纵的命名空间--------------------------------------------
@section[#:tag "mk-namespace"]{操纵的命名空间}

@tech{命名空间（namespace）}封装两条信息：

@itemize[

@item{从标识符到绑定的映射。例如，一个命名空间可以将标识符@racketidfont{lambda}映射到@racket[lambda]表。一个“空”的命名空间是一个映射之一，它映射每个标识符到一个未初始化的顶层变量。}

 @item{从模块名称到模块声明和实例的映射。}
]

第一个映射是用于对在一个顶层上下文中的表达式求值，如@racket[(eval '(lambda (x) (+ x 1)))]中的。第二个映射是用于定位模块，例如通过@racket[dynamic-require]。对@racket[(eval '(require racket/base))]的调用通常使用两部分：标识符映射确定@racket[require]的绑定；如果它原来的意思是@racketidfont{require}，那么模块映射用于定位@racketmodname[racket/base]模块。

从核心Racket运行系统的角度来看，所有求值都是反射性的。执行从初始的命名空间包含一些原始的模块，并进一步由命令行上或在@tech{REPL}提供指定加载的文件和模块。顶层@racket[require]表和@racket[define]表调整标识符映射，模块声明（通常根据@racket[require]表加载）调整模块映射。

@; 15.2.1 创建和安装命名空间----------------------------------------------------------
@subsection{创建和安装命名空间}

函数@racket[make-empty-namespace]创建一个新的空命名空间。由于命名空间确实是空的，所以它不能首先用来求值任何顶级表达式——甚至不能求值@racket[(require racket)]。特别地,

@racketblock[
(parameterize ([current-namespace (make-empty-namespace)])
  (namespace-require 'racket))
]

失败，因为命名空间不包括建立@racket[racket]的原始模块。

为了使命名空间有用，必须从现有命名空间中@deftech{附加（attached）}一些模块。附加模块通过从现有的命名空间的映射传递复制条目（模块及它的所有导入）调整模块名称映射到实例。通常情况下，而不是仅仅附加原始模块——其名称和组织有可能发生变化——附加一个高级模块，如@racketmodname[racket]或@racketmodname[racket/base]。

@racket[make-base-empty-namespace]函数提供一个空的命名空间，除非附加了@racketmodname[racket/base]。生成的命名空间仍然是“空的”，在这个意义上，绑定名称空间部分的标识符没有映射；只有模块映射已经填充。然而，通过初始模块映射，可以加载更多模块。

一个用@racket[make-base-empty-namespace]创建的命名空间适合于许多基本的动态任务。例如，假设@racketmodfont{my-dsl}库实现了一个特定定义域的语言，你希望在其中执行来自用户指定文件的命令。一个用@racket[make-base-empty-namespace]的命名空间足以启动：

@racketblock[
(define (run-dsl file)
  (parameterize ([current-namespace (make-base-empty-namespace)])
    (namespace-require 'my-dsl)
    (load file)))
]

注意，@racket[current-namespace]的@racket[parameterize]（参数）不影响像在@racket[parameterize]主体中的@racket[namespace-require]那样的标识符的意义。这些标识符从封闭上下文（可能是一个模块）获得它们的含义。只有对代码具有动态性的表达式，如@racket[load]（加载）的文件的内容，通过@racket[parameterize]（参数化）影响。

在上面的例子中，一个微妙的一点是使用@racket[(namespace-require 'my-dsl)]代替@racket[(eval
'(require my-dsl))]。后者不会运行，因为@racket[eval]需要对在命名空间中的@racket[require]获得意义，并且命名空间的标识符映射最初是空的。与此相反，@racket[namespace-require]函数直接将给定的模块导入（require）当前命名空间。从@racket[(namespace-require 'racket/base)]运行。从@racket[(namespace-require 'racket/base)]将为@racketidfont{require}引入绑定并使后续的@racket[(eval
'(require my-dsl))]运行。上面的比较好，不仅仅是因为它更紧凑，还因为它避免引入不属于特定领域语言的绑定。

@; 15.2.2 共享数据和代码的命名空间--------------------------------------------------
@subsection{共享数据和代码的命名空间}

如果不需要对新命名空间附加的模块，则将重新加载并实例化它们。例如，@racketmodname[racket/base]不包括@racketmodname[racket/class]，加载@racketmodname[racket/class]又将创造一个不同的类数据类型：

@interaction[
(require racket/class)
(class? object%)
(class?
 (parameterize ([current-namespace (make-base-empty-namespace)])
   (namespace-require 'racket/class) (code:comment @#,t{loads again})
   (eval 'object%)))
]

对于动态加载的代码需要与其上下文共享更多代码和数据的，使用@racket[namespace-attach-module]函数。 @racket[namespace-attach-module]的第一个参数是从中提取模块实例的源命名空间；在某些情况下，已知的当前命名空间包含需要共享的模块：

@interaction[
(require racket/class)
(class?
 (let ([ns (make-base-empty-namespace)])
   (namespace-attach-module (current-namespace)
                            'racket/class
                            ns)
   (parameterize ([current-namespace ns])
     (namespace-require 'racket/class) (code:comment @#,t{uses attached})
     (eval 'object%))))
]

然而，在一个模块中，@racket[define-namespace-anchor]和@racket[namespace-anchor->empty-namespace]的组合提供了一种更可靠的获取源命名空间的方法：

@racketmod[
racket/base

(require racket/class)

(define-namespace-anchor a)

(define (load-plug-in file)
  (let ([ns (make-base-empty-namespace)])
    (namespace-attach-module (namespace-anchor->empty-namespace a)
                             'racket/class
                              ns)
    (parameterize ([current-namespace ns])
      (dynamic-require file 'plug-in%))))
]

由@racket[namespace-attach-module]绑定的锚将模块的运行时间与加载模块的命名空间（可能与当前命名空间不同）连接在一起。在上面的示例中，由于封闭模块需要@racketmodname[racket/class]，由@racket[namespace-anchor->empty-namespace]生成的名称空间肯定包含了一个@racketmodname[racket/class]的实例。此外，该实例与一个导入模块的一个相同，因此类数据类型共享。

@; 15.3 脚本求值和使用load-------------------------------------------------------
@section[#:tag "load"]{脚本求值和使用@racket[load]}

从历史上看，Lisp实现没有提供模块系统。相反，大的程序是由基本的脚本@tech{REPL}来求值一个特定的顺序的程序片段。而@tech{REPL}脚本是结构化程序和库的好办法，它仍然有时是一个有用的性能。

@racket[load]函数通过从文件中一个接一个地@racket[read]（读取）S表达式来运行一个@tech{REPL}脚本，并把它们传递给@racket[eval]。如果一个文件@filepath{place.rkts}包含以下内容

@racketblock[
(define city "Salt Lake City")
(define state "Utah")
(printf "~a, ~a\n" city state)
]

那么，它可以@racket[load]（加载）进一个@tech{REPL}：

@interaction[
(eval:alts (load "place.rkts")
           (begin (define city "Salt Lake City")
                  (printf "~a, Utah\n" city)))
 city
]

然而，由于@racket[load]使用@racket[eval]，像下面的一个模块一般不会运行——基于@secref["namespaces"]（命名空间）中的相同原因描述：

@racketmod[
racket

(define there "Utopia")

(load "here.rkts")
]

对求值@filepath{here.rkts}的上下文的当前命名空间可能是空的；在任何情况下，你不能从@filepath{here.rkts}到@racket[there]（那里）。同时，在@filepath{here.rkts}里的任何定义对模块里的使用不会变得可见；毕竟，@racket[load]是动态发生，而在模块标识符引用是从词法上解决，因此是静态的。

不像@racket[eval]，@racket[load]不接受一个命名空间的参数。为了提供一个用于@racket[load]的命名空间，设置@racket[current-namespace]@tech{参数（parameter）}。下面的示例求值在@filepath{here.rkts}中使用@racketmodname[racket/base]模块绑定的表达式：

@racketmod[
racket

(parameterize ([current-namespace (make-base-namespace)])
  (load "here.rkts"))
]

你甚至可以使用@racket[namespace-anchor->namespace]使封闭模块的绑定可用于动态求值。在下面的例子中，当@filepath{here.rkts}被@racket[load]（加载）时，它既可以指@racket[there]，也可以指@racketmodname[racket]的绑定：

@racketmod[
racket

(define there "Utopia")

(define-namespace-anchor a)
(parameterize ([current-namespace (namespace-anchor->namespace a)])
  (load "here.rkts"))
]

不过，如果@filepath{here.rkts}定义任意的标识符，这个定义不能直接（即静态地）在外围模块中引用。

@racketmodname[racket/load]模块语言不同于@racketmodname[racket]或@racketmodname[racket/base]。一个模块使用@racketmodname[racket/load]对其所有上下文以动态对待，通过模块主体里的每一个表去@racket[eval]（使用以@racketmodname[racket]初始化的命名空间）。作为一个结果，@racket[eval]和@racket[load]在模块中的使用看到相同的动态命名空间作为直接主体表。例如，如果@filepath{here.rkts}包含以下内容

@racketblock[
(define here "Morporkia")
(define (go!) (set! here there))
]

那么运行

@racketmod[
racket/load

(define there "Utopia")

(load "here.rkts")

(go!)
(printf "~a\n" here)
]

打印“Utopia”。

使用@racketmodname[racket/load]的缺点包括减少错误检查、工具支持和性能。例如，用程序

@racketmod[
racket/load

(define good 5)
(printf "running\n")
good
bad
]

DrRacket的@onscreen{语法检查（Check Syntax）}工具不能告诉第二个@racket[good]是对第一个的参考，而对@racket[bad]的非绑定参考仅在运行时报告而不是在语法上拒绝。