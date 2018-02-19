;16.02.07.scrbl
16.2.7 语法污染
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "stx-certs" #:style 'quiet]{语法污染}

一个宏的一个使用可以扩展到一个标识符的使用，该标识符不会从绑定宏的模块中导出。一般来说，这样的标识符不必从扩展表达式中提取出来，并在不同的上下文中使用，因为使用不同上下文中的标识符可能会中断宏模块的不变量。

例如，下面的模块导出一个宏go，它扩展到unchecked-go的使用：

"m.rkt"

#lang racket
(provide go)
 
(define (unchecked-go n x)
  ; to avoid disaster, n must be a number
  (+ n 17))
 
(define-syntax (go stx)
  (syntax-case stx ()
   [(_ x)
    #'(unchecked-go 8 x)]))

如果对unchecked-go的引用从(go 'a)扩展解析，那么它可能会被插入一个新的表达，(unchecked-go #f 'a)，导致灾难。datum->syntax程序同样可用于构建一个导出标识符引用，即使没有宏扩展包括一个对标识符的引用。

为了防止这种滥用的导出标识符，这个宏go必须用syntax-protect明确保护其扩展：

(define-syntax (go stx)
  (syntax-case stx ()
   [(_ x)
    (syntax-protect #'(unchecked-go 8 x))]))

syntax-protect函数会导致从go被污染（tainted）的结果中提取的任何语法对象。宏扩展程序拒绝受污染的标识符，因此试图从(go 'a)的扩展中提取unchecked-go产生一个标识符，该标识符不能用于构造一个新表达式（或者，至少，不是宏扩展程序将接受的表达式）。syntax-rules、syntax-id-rule和define-syntax-rule表自动保护其扩展结果。

更确切地说，syntax-protect配备了一个带一个染料包（dye pack）的语法对象。当一个语法对象被配备时，那么syntax-e在它的结果污染任何语法对象。同样，它的当第一个参数被配备时，datum->syntax污染其结果。最后，如果引用的语法对象的任何部分被配备，则相应的部分将受到所生成的语法常数的影响。

当然，宏扩展本身必须能够解除（disarm）语法对象上的污染，以便它可以进一步扩展表达式或其子表达式。当一个语法对象配备有一个染料包时，染料包装有一个相关的检查者，可以用来解除染料包装。一个(syntax-protect stx)函数调用实际上是一个对(syntax-arm stx #f #t)的简写，这配备stx使用合适的检查程序。在试图扩展或编译它之前，扩展程序使用syntax-disarm并在每个表达式上使用它的检查程序。

与宏扩展程序从语法转换器的输入到其输出的属性（参见《语法对象属性》（Syntax Object Properties））相同，扩展程序将从转换器的输入复制染料包到输出。以前面的例子为基础，

"n.rkt"

#lang racket
(require "m.rkt")
 
(provide go-more)
 
(define y 'hello)
 
(define-syntax (go-more stx)
  (syntax-protect #'(go y)))

(go-more)的扩展介绍了一个对在(go y)中的非导出y的引用，以及扩展结果被装备，这样y不能从扩展中提取。即使go没有为其结果使用syntax-protect（可能归根到底是因为它不需要保护unchecked-go），(go y)上的染色包被传播给了最终扩展(unchecked-go 8 y)。宏扩展器使用syntax-rearm从转换程序的输入和输出增殖（propagate）染料包。

@;-------------------------------------------------
@section{Tainting Modes}

16.2.7.1 污染模式

在某些情况下，一个宏执行者有意允许有限的解构的宏结果没有污染结果。例如，给出define-like-y宏，

"q.rkt"

#lang racket
 
(provide define-like-y)
 
(define y 'hello)
 
(define-syntax (define-like-y stx)
  (syntax-case stx ()
    [(_ id) (syntax-protect #'(define-values (id) y))]))

也有人可以在内部定义中使用宏：

(let ()
  (define-like-y x)
  x)

“q.rkt”模块的执行器最有可能是希望允许define-like-y这样的使用。以转换一个内部定义为letrec绑定，但是通过define-like-y产生的define表必须解构，这通常会污染x的绑定和对y的引用。

相反，对define-like-y的内部使用是允许的，因为syntax-protect特别对待一个以define-values开始的语法列表。在这种情况下，代替装备整个表达式的是，语法列表中的每个元素都被装备，进一步将染料包推到列表的第二个元素中，以便它们被附加到定义的标识符上。因此，在扩展结果(define-values (x) y)中的define-values、x和y分别被装备，同时定义可以被解构以转化为letrec。

就像syntax-protect，通过将染料包推入这个列表元素，这个扩展程序重新装备一个以define-values开始的转换程序结果。作为一个结果，define-like-y已经实施产生(define id y)，它使用define代替define-values。在这种情况下，整个define表首先装备一个染料包，但是一旦define表扩展到define-values，染料包被移动到各个部分。

宏扩展程序以它处理以define-values开始的结果相同的方式处理以define-syntaxes开始的语法列表结果。从begin开始的语法列表结果同样被处理，除了语法列表的第二个元素被当作其它元素一样处理（即，直接元素被装备，而不是它的上下文）。此外，宏扩展程序递归地应用此特殊处理，以防宏生成包含嵌套define-values表的一个begin表。

通过将一个'taint-mode属性（见《语法对象属性》（Syntax Object Properties））附加到宏转换程序的结果语法对象中，可以覆盖染料包的默认应用程序。如果属性值是'opaque，那么语法对象被装备而且不是它的部件。如果属性值是'transparent，则语法对象的部件被装备。如果属性值是'transparent-binding，那么语法对象的部件和第二个部件的子部件（如define-values和define-syntaxes）被装备。'transparent和'transparent-binding模式触发递归属性在部件的检测，这样就可以把装备任意深入地推入到转换程序的结果中。

@;-----------------------------------------------------
@section[#:tag "taints+code-inspectors"]{Taints and Code Inspectors}

16.2.7.2 污染和代码检查

想要获得特权的工具（例如调试转换器）必须在扩展程序中解除染料包的作用。权限是通过代码检查器（code inspector）授予的。每个染料包的记录一个检查器，同时语法对象可以使用使用一个足够强大的检查器解除。

当声明一个模块时，该声明将捕获current-code-inspector参数的当前值。当模块中定义的宏转换器应用syntax-protect时，将使用捕获的检查器。一个工具可以通过提供与一个相同的检查器或模块检查器的超级检查器提供syntax-disarm对结果语法对象予以解除。在将current-code-inspector设置为不太强大的检查器（在加载了受信任的代码，如调试工具，之后），最终会运行不信任代码。

有了这种安排，宏生成宏需要小心些，因为正在生成的宏可以在已经生成的宏中嵌入语法对象，这些已经生成的宏需要正在生成的模块的保护等级，而不是包含已经生成的宏的模块的保护等级。为了避免这个问题，使用模块的声明时间检查器，它是可以作为(variable-reference->module-declaration-inspector (#%variable-reference))访问的，并使用它来定义一个syntax-protect的变体。

例如，假设go宏是通过宏实现的：

#lang racket
(provide def-go)
 
(define (unchecked-go n x)
  (+ n 17))
 
(define-syntax (def-go stx)
  (syntax-case stx ()
    [(_ go)
     (protect-syntax
      #'(define-syntax (go stx)
          (syntax-case stx ()
            [(_ x)
             (protect-syntax #'(unchecked-go 8 x))])))]))

当def-go被用于另一个模块定义go时，并且当go定义模块处于与def-go定义模块不同的保护等级时，生成的protect-syntax的宏使用是不正确的。在unchecked-go在def-go定义模块等级应该被保护，而不是go定义模块。

解决方案是定义和使用go-syntax-protect，而不是：

#lang racket
(provide def-go)
 
(define (unchecked-go n x)
  (+ n 17))
 
(define-for-syntax go-syntax-protect
  (let ([insp (variable-reference->module-declaration-inspector
               (#%variable-reference))])
    (lambda (stx) (syntax-arm stx insp))))
 
(define-syntax (def-go stx)
  (syntax-case stx ()
    [(_ go)
     (protect-syntax
      #'(define-syntax (go stx)
          (syntax-case stx ()
           [(_ x)
            (go-syntax-protect #'(unchecked-go 8 x))])))]))

@;------------------------------------------------------------------------
@section[#:tag "code-inspectors+protect"]{Protected Exports}

