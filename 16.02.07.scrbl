;16.02.07.scrbl
;16.2.7 语法污染
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "stx-certs" #:style 'quiet]{语法污染}

一个宏的一个使用可以扩展到一个标识符的使用，该标识符不会从绑定宏的模块中导出。一般来说，这样的标识符不必从扩展表达式中提取出来，并在不同的上下文中使用，因为使用不同上下文中的标识符可能会中断宏模块的不变量。

例如，下面的模块导出一个宏@racket[go]，它扩展到@racket[unchecked-go]的使用：

@racketmod[
#:file "m.rkt"
racket
(provide go)

(define (unchecked-go n x) 
  (code:comment @#,t{to avoid disaster, @racket[n] must be a number})
  (+ n 17))

(define-syntax (go stx)
  (syntax-case stx ()
   [(_ x)
    #'(unchecked-go 8 x)]))
]

如果对@racket[unchecked-go]的引用从@racket[(go 'a)]扩展解析，那么它可能会被插入一个新的表达，@racket[(unchecked-go #f 'a)]，导致灾难。@racket[datum->syntax]程序同样可用于构建一个导出标识符引用，即使没有宏扩展包括一个对标识符的引用。

为了防止这种滥用的导出标识符，这个宏@racket[go]必须用@racket[syntax-protect]明确保护其扩展：

@racketblock[
(define-syntax (go stx)
  (syntax-case stx ()
   [(_ x)
    (syntax-protect #'(unchecked-go 8 x))]))
]

@racket[syntax-protect]函数会导致从@racket[go]被@deftech{污染（tainted）}的结果中提取的任何语法对象。宏扩展程序拒绝受污染的标识符，因此试图从@racket[(go 'a)]的扩展中提取@racket[unchecked-go]产生一个标识符，该标识符不能用于构造一个新表达式（或者，至少，不是宏扩展程序将接受的表达式）。@racket[syntax-rules]、@racket[syntax-id-rule]和@racket[define-syntax-rule]表自动保护其扩展结果。

更确切地说，@racket[syntax-protect] @deftech{配备}了一个带一个@deftech{染料包（dye pack）}的语法对象。当一个语法对象被配备时，那么@racket[syntax-e]在它的结果污染任何语法对象。同样，它的当第一个参数被配备时，@racket[datum->syntax]污染其结果。最后，如果引用的语法对象的任何部分被配备，则相应的部分将受到所生成的语法常数的影响。

当然，宏扩展本身必须能够@deftech{解除（disarm）}语法对象上的污染，以便它可以进一步扩展表达式或其子表达式。当一个语法对象配备有一个染料包时，染料包装有一个相关的检查者，可以用来解除染料包装。一个@racket[(syntax-protect _stx)]函数调用实际上是一个对@racket[(syntax-arm _stx #f #t)]的简写，这配备@racket[_stx]使用合适的检查程序。在试图扩展或编译它之前，扩展程序使用@racket[syntax-disarm]并在每个表达式上使用它的检查程序。

与宏扩展程序从语法转换器的输入到其输出的属性（参见《@refsecref["stxprops"]》（Syntax Object Properties））相同，扩展程序将从转换器的输入复制染料包到输出。以前面的例子为基础，

@racketmod[
#:file "n.rkt"
racket
(require "m.rkt")

(provide go-more)

(define y 'hello)

(define-syntax (go-more stx)
  (syntax-protect #'(go y)))
]

@racket[(go-more)]的扩展介绍了一个对在@racket[(go y)]中的非导出@racket[y]的引用，以及扩展结果被装备，这样@racket[y]不能从扩展中提取。即使@racket[go]没有为其结果使用@racket[syntax-protect]（可能归根到底是因为它不需要保护@racket[unchecked-go]），@racket[(go y)]上的染色包被传播给了最终扩展@racket[(unchecked-go 8 y)]。宏扩展器使用@racket[syntax-rearm]从转换程序的输入和输出增殖（propagate）染料包。

@; 16.2.7.1 污染模式-------------------------------------------------
@section[#:tag "tainting-modes"]{污染模式}

在某些情况下，一个宏执行者有意允许有限的解构的宏结果没有污染结果。例如，给出@racket[define-like-y]宏，

@racketmod[
#:file "q.rkt"
racket

(provide define-like-y)

(define y 'hello)

(define-syntax (define-like-y stx)
  (syntax-case stx ()
    [(_ id) (syntax-protect #'(define-values (id) y))]))
]

也有人可以在内部定义中使用宏：

@racketblock[
(let ()
  (define-like-y x)
  x)
]

@filepath{q.rkt}模块的执行器最有可能是希望允许@racket[define-like-y]这样的使用。以转换一个内部定义为@racket[letrec]绑定，但是通过@racket[define-like-y]产生的@racket[define]表必须解构，这通常会污染@racket[x]的绑定和对@racket[y]的引用。

相反，对@racket[define-like-y]的内部使用是允许的，因为@racket[syntax-protect]特别对待一个以@racket[define-values]开始的语法列表。在这种情况下，代替装备整个表达式的是，语法列表中的每个元素都被装备，进一步将染料包推到列表的第二个元素中，以便它们被附加到定义的标识符上。因此，在扩展结果@racket[(define-values (x) y)]中的@racket[define-values]、@racket[x]和@racket[y]分别被装备，同时定义可以被解构以转化为@racket[letrec]。

就像@racket[syntax-protect]，通过将染料包推入这个列表元素，这个扩展程序重新装备一个以@racket[define-values]开始的转换程序结果。作为一个结果， @racket[define-like-y]已经实施产生@racket[(define id y)]，它使用@racket[define]代替@racket[define-values]。在这种情况下，整个@racket[define]表首先装备一个染料包，但是一旦@racket[define]表扩展到@racket[define-values]，染料包被移动到各个部分。

宏扩展程序以它处理以@racket[define-values]开始的结果相同的方式处理以@racket[define-syntaxes]开始的语法列表结果。从@racket[begin]开始的语法列表结果同样被处理，除了语法列表的第二个元素被当作其它元素一样处理（即，直接元素被装备，而不是它的上下文）。此外，宏扩展程序递归地应用此特殊处理，以防宏生成包含嵌套@racket[define-values]表的一个@racket[begin]表。

通过将一个@racket['taint-mode]属性（见《@refsecref["stxprops"]》（Syntax Object Properties））附加到宏转换程序的结果语法对象中，可以覆盖染料包的默认应用程序。如果属性值是@racket['opaque]，那么语法对象被装备而且不是它的部件。如果属性值是@racket['transparent]，则语法对象的部件被装备。如果属性值是@racket['transparent-binding]，那么语法对象的部件和第二个部件的子部件（如@racket[define-values]和@racket[define-syntaxes]）被装备。@racket['transparent]和@racket['transparent-binding]模式触发递归属性在部件的检测，这样就可以把装备任意深入地推入到转换程序的结果中。

@; 16.2.7.2 污染和代码检查-----------------------------------------------------
@section[#:tag "taints+code-inspectors"]{污染和代码检查}

想要获得特权的工具（例如调试转换器）必须在扩展程序中解除染料包的作用。权限是通过 @deftech{代码检查器（code inspector）}授予的。每个染料包的记录一个检查器，同时语法对象可以使用使用一个足够强大的检查器解除。

当声明一个模块时，该声明将捕获@racket[current-code-inspector]参数的当前值。当模块中定义的宏转换器应用@racket[syntax-protect]时，将使用捕获的检查器。一个工具可以通过提供与一个相同的检查器或模块检查器的超级检查器提供@racket[syntax-disarm]对结果语法对象予以解除。在将@racket[current-code-inspector]设置为不太强大的检查器（在加载了受信任的代码，如调试工具，之后），最终会运行不信任代码。

有了这种安排，宏生成宏需要小心些，因为正在生成的宏可以在已经生成的宏中嵌入语法对象，这些已经生成的宏需要正在生成的模块的保护等级，而不是包含已经生成的宏的模块的保护等级。为了避免这个问题，使用模块的声明时间检查器，它是可以作为@racket[(variable-reference->module-declaration-inspector
(#%variable-reference))]访问的，并使用它来定义一个@racket[syntax-protect]的变体。

例如，假设@racket[go]宏是通过宏实现的：

@racketmod[
racket
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
]

当@racket[def-go]被用于另一个模块定义@racket[go]时，并且当@racket[go]定义模块处于与@racket[def-go]定义模块不同的保护等级时，生成的@racket[protect-syntax]的宏使用是不正确的。在@racket[unchecked-go]在@racket[def-go]定义模块等级应该被保护，而不是@racket[go]定义模块。

解决方案是定义和使用@racket[go-syntax-protect]，而不是：

@racketmod[
racket
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
]

@;------------------------------------------------------------------------
@;@section[#:tag "code-inspectors+protect"]{Protected Exports}
@section[#:tag "code-inspectors+protect"]{受保护的导出}

@;{Sometimes, a module needs to export bindings to some modules---other
modules that are at the same trust level as the exporting module---but
prevent access from untrusted modules. Such exports should use the
@racket[protect-out] form in @racket[provide]. For example,
@racket[ffi/unsafe] exports all of its unsafe bindings as
@deftech{protected} in this sense.}

有时，一个模块需要将绑定导出到一些模块——其它与导出模块在同一信任级别上的模块——但阻止不受信任模块的访问。此类导出应使用@racket[provide]中的@racket[protect-out]表。例如,@racket[ffi/unsafe]导出所有的非安全绑定作为从这个意义上讲的@deftech{受保护的（protected）}。

@;{Code inspectors, again, provide the mechanism for determining which
modules are trusted and which are untrusted. When a module is
declared, the value of @racket[current-code-inspector] is associated
to the module declaration. When a module is instantiated (i.e., when the
body of the declaration is actually executed), a sub-inspector is
created to guard the module's exports. Access to the module's
@tech{protected} exports requires a code inspector higher in the
inspector hierarchy than the module's instantiation inspector; note
that a module's declaration inspector is always higher than its
instantiation inspector, so modules are declared with the same code
inspector can access each other's exports.}

代码检查器再次提供了这个机制，它确定哪一个模块是可信的以及哪一个模块是不可信的。当一个模块被声明时，@racket[current-code-inspector]的值被关联到模块声明。当一个模块被实例化时（即当声明的主体实际上被执行了），一个子检查器被创建来保护模块的导出。对模块的@tech{受保护的（protected）}导出的访问需要一个在检查器层次结构上比这个模块的实例化检查器更高级别的代码检查器；注意一个模块的声明检查器总是高于它的实例化检查器，因此模块以相同的代码声明检查器可以访问其它每一个的导出。

@;{Syntax-object constants within a module, such as literal identifiers
in a template, retain the inspector of their source module. In this
way, a macro from a trusted module can be used within an untrusted
module, and @tech{protected} identifiers in the macro expansion still
work, even through they ultimately appear in an untrusted
module. Naturally, such identifiers should be @tech{arm}ed, so that
they cannot be extracted from the macro expansion and abused by
untrusted code.}

在一个模块中的语法对象常量，如在一个模板中的文字标识符，保留它们的源模块的检查器。以这方式，来自于一个受信任的模块的一个宏可以在不可信的模块内使用，同时宏扩展中的@tech{受保护的（protected）}标识符一直在工作，即使通过它们最终出现在不可信的模块中。当然，这样的标识符应该被@tech{装备（arm）}，所以它们不能从宏扩展中提取并被非信任代码滥用。

@;{Compiled code from a @filepath{.zo} file is inherently untrustworthy,
unfortunately, since it can be synthesized by means other than
@racket[compile]. When compiled code is written to a @filepath{.zo}
file, syntax-object constants within the compiled code lose their
inspectors. All syntax-object constants within compiled code acquire
the enclosing module's declaration-time inspector when the code is
loaded.}

不幸的是，因为它可以用除了@racket[编译（compile）]之外的其它方法合成，因此来自于一个@filepath{.zo}文件的被编译代码本质上是不可信的。当编译后的代码写入到一个@filepath{.zo}文件中，编译代码中的语法对象常量就失去了检查器。当代码加载时，已编译代码中的所有语法对象常量获得封闭模块的声明时间检查器。
