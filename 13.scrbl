;13.scrbl
;13 类和对象
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          racket/class
          "guide-utils.rkt"
          (for-label racket/class
                     racket/trait
                     racket/contract))

@(define class-eval
   (let ([e (make-base-eval)])
     (e '(require racket/class))
     e))

@title[#:tag "classes"]{类和对象}

一个@racket[类（class）]表达式表示一类值，就像一个@racket[lambda]表达式一样：

@specform[(class superclass-expr decl-or-expr ...)]
 @racket[_superclass-expr]确定为新类的基类。每个@racket[_decl-or-expr]既是一个声明，关系到对方法、字段和初始化参数，也是一个表达式，每次求值就实例化类。换句话说，与方法之类的构造器不同，类具有与字段和方法声明交错的初始化表达式。

按照惯例，类名以@racketidfont{%}结束。内置根类是@racket[object%]。下面的表达式用公共方法@racket[get-size]、@racket[grow]和@racket[eat]创建一个类：

@racketblock[
(class object%
  (init size)                (code:comment #,(t "初始化参数"))

  (define current-size size) (code:comment #,(t "字段"))

  (super-new)                (code:comment #,(t "基类初始化"))

  (define/public (get-size)
    current-size)

  (define/public (grow amt)
    (set! current-size (+ amt current-size)))

  (define/public (eat other-fish)
    (grow (send other-fish get-size))))
]

@(interaction-eval
#:eval class-eval
(define fish%
  (class object%
    (init size)
    (define current-size size)
    (super-new)
    (define/public (get-size)
      current-size)
    (define/public (grow amt)
      (set! current-size (+ amt current-size)))
    (define/public (eat other-fish)
      (grow (send other-fish get-size))))))

当通过@racket[new]表实例化类时，@racket[size]的初始化参数必须通过一个命名参数提供：

@racketblock[
(new (class object% (init size) ....) [size 10])
]

当然，我们还可以命名类及其实例：

@racketblock[
(define fish% (class object% (init size) ....))
(define charlie (new fish% [size 10]))
]

@(interaction-eval
#:eval class-eval
(define charlie (new fish% [size 10])))

在@racket[fish%]的定义中，@racket[current-size]是一个以@racket[size]值初始化参数开头的私有字段。像@racket[size]这样的初始化参数只有在类实例化时才可用，因此不能直接从方法引用它们。与此相反，@racket[current-size]字段可用于方法。

在@racket[class]中的@racket[(super-new)]表达式调用基类的初始化。在这种情况下，基类是@racket[object%]，它没有带初始化参数也没有执行任何工作；必须使用@racket[super-new]，因为一个类总必须总是调用其基类的初始化。

初始化参数、字段声明和表达式如@racket[(super-new)]可以以@racket[类（class）]中的任何顺序出现，并且它们可以与方法声明交织在一起。类中表达式的相对顺序决定了实例化过程中的求值顺序。例如，如果一个字段的初始值需要调用一个方法，它只有在基类初始化后才能工作，然后字段声明必须放在@racket[super-new]调用后。以这种方式排序字段和初始化声明有助于规避不可避免的求值。方法声明的相对顺序对求值没有影响，因为方法在类实例化之前被完全定义。

@; 13.1 方法----------------------------------------------
@section[#:tag "methods"]{方法}

@racket[fish%]中的三个@racket[define/public]声明都引入了一种新方法。声明使用与Racket函数相同的语法，但方法不能作为独立函数访问。调用@racket[fish%]对象的@racket[grow]方法需要@racket[send]表：

@interaction[
#:eval class-eval
(send charlie grow 6)
(send charlie get-size)
]

在@racket[fish%]中，自方法可以被像函数那样调用，因为方法名在作用域中。例如，@racket[fish%]中的@racket[eat]方法直接调用@racket[grow]方法。在类中，试图以除方法调用以外的任何方式使用方法名会导致语法错误。

在某些情况下，一个类必须调用由基类提供但不能被重写的方法。在这种情况下，类可以使用带@racket[this]的@racket[send]来访问该方法：

@def+int[
#:eval class-eval
(define hungry-fish% (class fish% (super-new)
                       (define/public (eat-more fish1 fish2)
                         (send this eat fish1)
                         (send this eat fish2))))
]

另外，类可以声明一个方法使用@racket[inherit]（继承）的存在，该方法将方法名引入到直接调用的作用域中：

@def+int[
#:eval class-eval
(define hungry-fish% (class fish% (super-new)
                       (inherit eat)
                       (define/public (eat-more fish1 fish2)
                         (eat fish1) (eat fish2))))
]

在@racket[inherit]声明中，如果@racket[fish%]没有提供一个@racket[eat]方法，那么在对 @racket[hungry-fish%]类表的求值中会出现一个错误。与此相反，用@racket[(send this ....)]，直到@racket[eat-more]方法被调和@racket[send]表被求值前不会发出错误信号。因此，@racket[inherit]是首选。

@racket[send]的另一个缺点是它比@racket[inherit]效率低。一个方法的请求通过@racket[send]调用寻找在运行时在目标对象的类的方法，使@racket[send]类似于java方法调用接口。相反，基于@racket[inherit]的方法调用使用一个类的方法表中的偏移量，它在类创建时计算。

为了在从方法类之外调用方法时实现与继承方法调用类似的性能，程序员必须使用@racket[generic]（泛型）表，它生成一个特定类和特定方法的@defterm{generic方法}，用@racket[send-generic]调用：

@def+int[
#:eval class-eval
(define get-fish-size (generic fish% get-size))
(send-generic charlie get-fish-size)
(send-generic (new hungry-fish% [size 32]) get-fish-size)
(send-generic (new object%) get-fish-size)
]

粗略地说，表单将类和外部方法名转换为类方法表中的位置。如上一个例子所示，通过泛型方法发送检查它的参数是泛型类的一个实例。


是否在@racket[class]内直接调用方法，通过泛型方法，或通过@racket[send]，方法以通常的方式重写工程：

@defs+int[
#:eval class-eval
[
(define picky-fish% (class fish% (super-new)
                      (define/override (grow amt)
                        ;; Doesn't eat all of its food
                        (super grow (* 3/4 amt)))))
(define daisy (new picky-fish% [size 20]))
]
(send daisy eat charlie)
(send daisy get-size)
]

在@racket[picky-fish%]的@racket[grow]方法是用@racket[define/override]声明的，而不是 @racket[define/public]，因为@racket[grow]是作为一个重写的申明的意义。如果@racket[grow]已经用@racket[define/public]声明，那么在对类表达式求值时会发出一个错误，因为@racket[fish%]已经提供了@racket[grow]。

使用@racket[define/override]也允许通过@racket[super]调用调用重写的方法。例如，@racket[grow]在@racket[picky-fish%]实现使用@racket[super]代理给基类的实现。

@;13.2 初始化参数-----------------------------------------
@section[#:tag "initargs"]{初始化参数}

因为@racket[picky-fish%]申明没有任何初始化参数，任何初始化值在@racket[(new picky-fish% ....)]里提供都被传递给基类的初始化，即传递给@racket[fish%]。子类可以在@racket[super-new]调用其基类时提供额外的初始化参数，这样的初始化参数会优先于参数提供给@racket[new]。例如，下面的@racket[size-10-fish%]类总是产生大小为10的鱼：

@def+int[
#:eval class-eval
(define size-10-fish% (class fish% (super-new [size 10])))
(send (new size-10-fish%) get-size)
]

就@racket[size-10-fish%]来说，用@racket[new]提供一个@racket[size]初始化参数会导致初始化错误；因为在@racket[super-new]里的@racket[size]优先，@racket[size]提供给@racket[new]没有目标申明。

如果@racket[class]表声明一个默认值，则初始化参数是可选的。例如，下面的@racket[default-10-fish%]类接受一个@racket[size]的初始化参数，但如果在实例里没有提供值那它的默认值是10：

@def+int[
#:eval class-eval
(define default-10-fish% (class fish%
                           (init [size 10])
                           (super-new [size size])))
(new default-10-fish%)
(new default-10-fish% [size 20])
]

在这个例子中，@racket[super-new]调用传递它自己的@racket[size]值作为@racket[size]初始化初始化参数传递给基类。

@; 13.3 内部和外部名称-------------------------------------------------
@section[#:tag "intnames"]{内部和外部名称}

在@racket[default-10-fish%]中@racket[size]的两个使用揭示了类成员标识符的双重身份。当@racket[size]是@racket[new]或@racket[super-new]中的一个括号对的第一标识符，@racket[size]是一个@defterm{外部名称（external name）}，象征性地匹配到类中的初始化参数。当@racket[size]作为一个表达式出现在@racket[default-10-fish%]中，@racket[size]是一个@defterm{内部名称（internal name）}，它是词法作用域。类似地，对继承的@racket[eat]方法的调用使用@racket[eat]作为内部名称，而一个@racket[eat]的@racket[send]的使用作为一个外部名称。

@racket[class]表的完整语法允许程序员为类成员指定不同的内部和外部名称。由于内部名称是本地的，因此可以重命名它们，以避免覆盖或冲突。这样的改名不总是必要的，但重命名缺乏的解决方法可以是特别繁琐。

@;13.4 接口（Interface）-------------------------------------------------
@section[#:tag "Interfaces"]{接口（Interface）}

接口对于检查一个对象或一个类实现一组具有特定（隐含）行为的方法非常有用。接口的这种使用有帮助的，即使没有静态类型系统（那是java有接口的主要原因）。

Racket中的接口通过使用@racket[interface]表创建，它只声明需要去实现的接口的方法名称。接口可以扩展其它接口，这意味着接口的实现会自动实现扩展接口。

@specform[(interface (superinterface-expr ...) id ...)]

为了声明一个实现一个接口的类，必须使用@racket[class*]表代替@racket[class]：

@specform[(class* superclass-expr (interface-expr ...) decl-or-expr ...)]

例如，我们不必强制所有的@racket[fish%]类都是源自于@racket[fish%]，我们可以定义@racket[fish-interface]并改变@racket[fish%]类来声明它实现了@racket[fish-interface]：

@racketblock[
(define fish-interface (interface () get-size grow eat))
(define fish% (class* object% (fish-interface) ....))
]

如果@racket[fish%]的定义不包括@racket[get-size]、@racket[grow]和@racket[eat]方法，那么在@racket[class*]表求值时会出现错误，因为实现@racket[fish-interface]接口需要这些方法。

@racket[is-a?]判断接受一个对象作为它的第一个参数，同时类或接口作为它的第二个参数。当给了一个类，无论对象是该类的实例或者派生类的实例，@racket[is-a?]都执行检查。当给一个接口，无论对象的类是否实现接口，@racket[is-a?]都执行检查。另外，@racket[implementation?]判断检查给定类是否实现给定接口。

@; 13.5 Final、Augment和Inner--------------------------------------
@section[#:tag "inner"]{Final、Augment和Inner}

在java中，一个@racket[class]表的方法可以被指定为@defterm{最终的（final）}，这意味着一个子类不能重写方法。一个最终方法是使用@racket[public-final]或@racket[override-final]申明，取决于声明是为一个新方法还是一个重写实现。

在允许与不允许任意完全重写的两个极端之间，类系统还支持Beta类型的@defterm{可扩展（augmentable）}方法。一个带@racket[pubment]声明的方法类似于@racket[public]，但方法不能在子类中重写；它仅仅是可扩充。一个@racket[pubment]方法必须显式地使用@racket[inner]调用一个扩展（如果有）；一个子类使用@racket[pubment]扩展方法，而不是使用@racket[override]。

一般来说，一个方法可以在类派生的扩展模式和重写模式之间进行切换。@racket[augride]方法详述表明了一个扩展，这里这个扩展本身在子类中是可重写的的方法（虽然这个基类的实现不能重写）。同样，@racket[overment]重写一个方法并使得重写的实现变得可扩展。

@; 13.6 控制外部名称的范围-------------------------------------------------
@section[#:tag "extnames"]{控制外部名称的范围}

正如《@secref["intnames"]》（Internal and External Names）所指出的，类成员既有内部名称，也有外部名称。成员定义在本地绑定内部名称，此绑定可以在本地重命名。与此相反，外部名称默认情况下具有全局范围，成员定义不绑定外部名称。相反，成员定义指的是外部名称的现有绑定，其中成员名绑定到@defterm{成员键（member key）}；一个类最终将成员键映射到方法、字段和初始化参数。

回头看@racket[hungry-fish%]类（@racket[class]）表达式：

@racketblock[
(define hungry-fish% (class fish% ....
                       (inherit eat)
                       (define/public (eat-more fish1 fish2)
                         (eat fish1) (eat fish2))))
]

在求值过程中@racket[hungry-fish%]类和@racket[fish%]类指相同的@racket[eat]的全局绑定。在运行时，在@racket[hungry-fish%]中调用@racket[eat]是通过共享绑定到@racket[eat]的方法键和@racket[fish%]中的@racket[eat]方法相匹配。

对外部名称的默认绑定是全局的，但程序员可以用@racket[define-member-name]表引入外部名称绑定。

@specform[(define-member-name id member-key-expr)]

特别是，通过使用@racket[(generate-member-key)]作为@racket[member-key-expr]，外部名称可以为一个特定的范围局部化，因为生成的成员键范围之外的访问。换句话说，@racket[define-member-name]给外部名称一种私有包范围，但从包中概括为Racket中的任意绑定范围。

例如，下面的@racket[fish%]类和@racket[pond%]类通过一个@racket[get-depth]方法配合，只有这个配合类可以访问：

@racketblock[
(define-values (fish% pond%) (code:comment #,(t "两个相互递归类"))
  (let () ; 创建本地定义范围
    (define-member-name get-depth (generate-member-key))
    (define fish%
      (class ....
        (define my-depth ....)
	(define my-pond ....)
	(define/public (dive amt)
        (set! my-depth
              (min (+ my-depth amt)
                   (send my-pond get-depth))))))
    (define pond%
      (class ....
        (define current-depth ....)
        (define/public (get-depth) current-depth)))
    (values fish% pond%)))
]

外部名称在名称空间中，将它们与其它Racket名称分隔开。这个单独的命名空间被隐式地用于@racket[send]中的方法名、在@racket[new]中的初始化参数名称，或成员定义中的外部名称。特殊表 @racket[member-name-key]提供对任意表达式位置外部名称的绑定的访问：@racket[(member-name-key id)]在当前范围内生成@racket[id]的成员键绑定。

成员键值主要用于@racket[define-member-name]表。通常，@racket[(member-name-key id)]捕获@racket[id]的方法键，以便它可以在不同的范围内传递到@racket[define-member-name]的使用。这种能力证明推广混合是有用的，作为接下来的讨论。

@; 13.7 混合（mixin）------------------------------------------------------
@section[#:tag "Mixins"]{混合（mixin）}

因为@racket[class]（类）是一种表达表，而不是如同在Smalltalk和java里的一个顶级的声明，一个@racket[class]表可以嵌套在任何词法范围内，包括lambda（λ）。其结果是一个@deftech{混合（mixin）}，即，一个类的扩展，是相对于它的基类的参数化。

例如，我们可以参数化@racket[picky-fish%]类来覆盖它的基类从而定义@racket[picky-mixin]：

@racketblock[
(define (picky-mixin %)
  (class % (super-new)
    (define/override (grow amt) (super grow (* 3/4 amt)))))
(define picky-fish% (picky-mixin fish%))
]

Smalltalk风格类和Racket类之间的许多小的差异有助于混合的有效利用。特别是，@racket[define/override]的使用使得@racket[picky-mixin]期望一个类带有一个@racket[grow]方法更明确。如果@racket[picky-mixin]应用于一个没有@racket[grow]方法的类，一旦应用@racket[picky-mixin]则会发出一个错误的信息。

同样，当应用混合时使用@racket[inherit]（继承）执行“方法存在（method existence）”的要求：

@racketblock[
(define (hungry-mixin %)
  (class % (super-new)
    (inherit eat)
    (define/public (eat-more fish1 fish2) 
      (eat fish1) 
      (eat fish2))))
]

mixin的优势是，我们可以很容易地将它们结合起来以创建新的类，其共享的实现不适合一个继承层次——没有多继承相关的歧义。配备@racket[picky-mixin]和@racket[hungry-mixin]，为“hungry”创造了一个类，但“picky fish”是直截了当的：

@racketblock[
(define picky-hungry-fish% 
  (hungry-mixin (picky-mixin fish%)))
]

关键词初始化参数的使用是混合的易于使用的重点。例如，@racket[picky-mixin]和@racket[hungry-mixin]可以通过合适的@racket[eat]方法和@racket[grow]方法增加任何类，因为它们在它们的@racket[super-new]表达式里没有指定初始化参数也没有添加东西：

@racketblock[
(define person% 
  (class object%
    (init name age)
    ....
    (define/public (eat food) ....)
    (define/public (grow amt) ....)))
(define child% (hungry-mixin (picky-mixin person%)))
(define oliver (new child% [name "Oliver"] [age 6]))
]

最后，对类成员的外部名称的使用（而不是词法作用域标识符）使得混合使用很方便。添加@racket[picky-mixin]到@racket[person%]运行，因为这个名字@racket[eat]和@racket[grow]匹配，在@racket[fish%]和@racket[person%]里没有任何@racket[eat]和@racket[grow]的优先申明可以是同样的方法。当成员名称意外碰撞后，此特性是一个潜在的缺陷；一些意外冲突可以通过限制外部名称作用域来纠正，就像在《@secref["extnames"]（Controlling the Scope of External Names）》所讨论的那样。

@; 13.7.1 混合和接口--------------------------------------------------------------
@subsection[#:tag "Mixins-and-Interfaces"]{混合和接口}

使用@racket[implementation?]，@racket[picky-mixin]可以要求其基类实现@racket[grower-interface]，这可以是由@racket[fish%]和@racket[person%]实现：

@racketblock[
(define grower-interface (interface () grow))
(define (picky-mixin %)
  (unless (implementation? % grower-interface)
    (error "picky-mixin: not a grower-interface class"))
  (class % ....))
]

另一个使用带混合的接口是标记类通过混合产生，因此，混合实例可以被识别。换句话说，@racket[is-a?]不能在一个混合上体现为一个函数运行，但它可以识别为一个接口（有点像一个@defterm{特定的接口}），它总是被混合所实现。例如，通过@racket[picky-mixin]生成的类可以被@racket[picky-interface]所标记，使是@racket[is-picky?]去判定:

@racketblock[
(define picky-interface (interface ()))
(define (picky-mixin %)
  (unless (implementation? % grower-interface)
    (error "picky-mixin: not a grower-interface class"))
  (class* % (picky-interface) ....))
(define (is-picky? o)
  (is-a? o picky-interface))
]

@; 13.7.2 mixin表--------------------------------------------------
@subsection[#:tag "The-mixin-Form"]{The @racket[mixin]表}

为执行混合而编纂@racket[lambda]加@racket[class]模式，包括对混合的定义域和值域接口的使用，类系统提供了一个@racket[mixin]宏：

@specform[
(mixin (interface-expr ...) (interface-expr ...)
  decl-or-expr ...)
]

@racket[interface-expr]的第一个集合确定混合的定义域，第二个集合确定值域。就是说，扩张是一个函数，它测试是否一个给定的基类实现@racket[interface-expr]的第一个序列，并产生一个类实现@racket[interface-expr]的第二个序列。其它要求，如在基类的继承方法的存在，然后检查@racket[mixin]表的@racket[class]扩展。例如:

@interaction[
#:eval class-eval

(define choosy-interface (interface () choose?))
(define hungry-interface (interface () eat))
(define choosy-eater-mixin
  (mixin (choosy-interface) (hungry-interface)
    (inherit choose?)
    (super-new)
    (define/public (eat x)
      (cond
        [(choose? x)
         (printf "chomp chomp chomp on ~a.\n" x)]
        [else
         (printf "I'm not crazy about ~a.\n" x)]))))

(define herring-lover% 
  (class* object% (choosy-interface)
    (super-new)
    (define/public (choose? x)
      (regexp-match #px"^herring" x))))

(define herring-eater% (choosy-eater-mixin herring-lover%))
(define eater (new herring-eater%))
(send eater eat "elderberry")
(send eater eat "herring")
(send eater eat "herring ice cream")
]

混合不仅覆盖方法，并引入公共方法，它们也可以扩展方法，引入扩展的方法，添加一个可重写的扩展，并添加一个可扩展的覆盖——所有这些事一个类都能完成（参见《@secref["inner"]》部分）。

@; 13.7.3 参数化的混合------------------------------------------------
@subsection[#:tag "parammixins"]{参数化的混合}

正如在《@secref["extnames"]》（Controlling the Scope of External Names）中指出的，外部名称可以用@racket[define-member-name]绑定。这个工具允许一个混合用定义或使用的方法概括。例如，我们可以通过对@racket[eat]的外部成员键的使用参数化@racket[hungry-mixin]：

@racketblock[
(define (make-hungry-mixin eat-method-key)
  (define-member-name eat eat-method-key)
  (mixin () () (super-new)
    (inherit eat)
    (define/public (eat-more x y) (eat x) (eat y))))
]

获得一个特定的hungry-mixin，我们必须应用这个函数到一个成员键，它指向一个适当的@racket[eat]方法，我们可以获得 @racket[member-name-key]的使用：

@racketblock[
((make-hungry-mixin (member-name-key eat))
 (class object% .... (define/public (eat x) 'yum)))
]

以上，我们应用@racket[hungry-mixin]给一个匿名类，它提供@racket[eat]，但我们也可以把它和一个提供@racket[chomp]的类组合，相反：

@racketblock[
((make-hungry-mixin (member-name-key chomp))
 (class object% .... (define/public (chomp x) 'yum)))
]

@; 13.8 特征（trait）----------------------------------------------------------
@section[#:tag "Traits"]{特征（trait）}

一个@defterm{特征（trait）}类似于一个mixin，它封装了一组方法添加到一个类里。一个特征不同于一个mixin，它自己的方法是可以用特征运算符操控的，比如@racket[trait-sum]（合并这两个特征的方法）、@racket[trait-exclude]（从一个特征中移除方法）以及@racket[trait-alias]（添加一个带有新名字的方法的拷贝；它不重定向到对任何旧名字的调用）。

混合和特征之间的实际差别是两个特征可以组合，即使它们包括了共有的方法，而且即使两者的方法都可以合理地覆盖其它方法。在这种情况下，程序员必须明确地解决冲突，通常通过混淆方法，排除方法，以及合并使用别名的新特性。

假设我们的@racket[fish%]程序员想要定义两个类扩展，@racket[spots]和@racket[stripes]，每个都包含@racket[get-color]方法。fish的spot不应该覆盖的stripe，反之亦然；相反，一个@racket[spots+stripes-fish%]应结合两种颜色，这是不可能的如果@racket[spots]和@racket[stripes]是普通混合实现。然而，如果spots和stripes作为特征来实现，它们可以组合在一起。首先，我们在每个特征中给@racket[get-color]起一个别名为一个不冲突的名称。第二，@racket[get-color]方法从两者中移除，只有别名的特征被合并。最后，新特征用于创建一个类，它基于这两个别名引入自己的@racket[get-color]方法，生成所需的@racket[spots+stripes]扩展。

@; 13.8.1 特征作为混合集-----------------------------------------------------------
@subsection[#:tag "Traits-as-Sets-of-Mixins"]{特征作为混合集}

在Racket里实现特征的一个自然的方法是如同一组混合，每个特征方法带一个mixin。例如，我们可以尝试如下定义spots和stripes的特征，使用关联列表来表示集合：

@racketblock[
(define spots-trait
  (list (cons 'get-color 
               (lambda (%) (class % (super-new)
                             (define/public (get-color) 
                               'black))))))
(define stripes-trait
  (list (cons 'get-color 
              (lambda (%) (class % (super-new)
                            (define/public (get-color) 
                              'red))))))
]

一个集合的表示，如上面所述，允许@racket[trait-sum]和@racket[trait-exclude]做为简单操作；不幸的是，它不支持@racket[trait-alias]运算符。虽然一个混合可以在关联表里复制，混合有一个固定的方法名称，例如，@racket[get-color]，而且混合不支持方法重命名操作。支持@racket[trait-alias]，我们必须在扩展方法名上参数化混合，同样地@racket[eat]在参数化混合（@secref["parammixins"]）中进行参数化。

为了支持@racket[trait-alias]操作，@racket[spots-trait]应表示为：

@racketblock[
(define spots-trait
  (list (cons (member-name-key get-color)
              (lambda (get-color-key %) 
                (define-member-name get-color get-color-key)
                (class % (super-new)
                  (define/public (get-color) 'black))))))
]

当@racket[spots-trait]中的@racket[get-color]方法是给@racket[get-trait-color]的别名并且@racket[get-color]方法被去除，由此产生的特性如下：

@racketblock[
(list (cons (member-name-key get-trait-color)
            (lambda (get-color-key %)
              (define-member-name get-color get-color-key)
              (class % (super-new)
                (define/public (get-color) 'black)))))
]

应用特征@racket[_T]到一个类@racket[_C]和获得一个派生类，我们用@racket[((trait->mixin _T) _C)]。@racket[trait->mixin]函数用给混合的方法和部分 @racket[_C]扩展的键提供每个@racket[_T]的混合：

@racketblock[
(define ((trait->mixin T) C)
  (foldr (lambda (m %) ((cdr m) (car m) %)) C T))
]

因此，当上述特性与其它特性结合，然后应用到类中时，@racket[get-color]的使用将成为外部名称@racket[get-trait-color]的引用。

@; 13.8.2 特征的继承与基类----------------------------------------------------------
@subsection[#:tag "Inherit-and-Super-in-Traits"]{特征的继承与基类}

特性的这个第一个实现支持@racket[trait-alias]，它支持一个调用自身的特性方法，但是它不支持调用彼此的特征方法。特别是，假设一个spot-fish的市场价值取决于它的斑点颜色：

@racketblock[
(define spots-trait
  (list (cons (member-name-key get-color) ....)
        (cons (member-name-key get-price)
              (lambda (get-price %) ....
                (class % ....
                  (define/public (get-price) 
                    .... (get-color) ....))))))
]

在这种情况下，@racket[spots-trait]的定义失败，因为@racket[get-color]是不在@racket[get-price]混合范围之内。事实上，当特征应用于一个类时依赖于混合程序的顺序，当@racket[get-price]混合应用于类时@racket[get-color]方法可能不可获得。因此添加一个@racket[(inherit get-color)]申明给@racket[get-price]混合并不解决问题。

一种解决方案是要求在像@racket[get-price]方法中使用@racket[(send this get-color)]。这种更改是有效的，因为@racket[send]总是延迟方法查找，直到对方法的调用被求值。然而，延迟查找比直接调用更为昂贵。更糟糕的是，它也延迟检查@racket[get-color]方法是否存在。

第二个，实际上，并且有效的解决方案是改变特征编码。具体来说，我们代表每个方法作为一对混合：一个引入方法，另一个实现它。当一个特征应用于一个类，所有的引入方法混合首先被应用。然后实现方法混合可以使用@racket[inherit]去直接访问任何引入的方法。

@racketblock[
(define spots-trait
  (list (list (local-member-name-key get-color)
              (lambda (get-color get-price %) ....
                (class % ....
                  (define/public (get-color) (void))))
              (lambda (get-color get-price %) ....
                (class % ....
                  (define/override (get-color) 'black))))
        (list (local-member-name-key get-price)
              (lambda (get-price get-color %) ....
                (class % ....
                  (define/public (get-price) (void))))
              (lambda (get-color get-price %) ....
                (class % ....
                  (inherit get-color)
                  (define/override (get-price)
                    .... (get-color) ....))))))
]

有了这个特性编码，  @racket[trait-alias]添加一个带新名称的新方法，但它不会改变对旧方法的任何引用。

@; 13.8.3 trait（特征）表----------------------------------------------------
@subsection[#:tag "The-trait-Form"]{@racket[trait]（特征）表}

通用特性模式显然对程序员直接使用来说太复杂了，但很容易在@racket[trait]宏中编译：

@specform[
(trait trait-clause ...)
]

在可选项的@racket[inherit]（继承）从句中的@racket[id]对@racket[expr]方法中的直接引用是有效的，并且它们必须提供其它特征或者基类，其特征被最终应用。

使用这个表结合特征操作符，如@racket[trait-sum]、@racket[trait-exclude]、@racket[trait-alias]和@racket[trait->mixin],我们可以实现@racket[spots-trait]和@racket[stripes-trait]作为所需。

@racketblock[
(define spots-trait
  (trait
    (define/public (get-color) 'black)
    (define/public (get-price) ... (get-color) ...)))

(define stripes-trait
  (trait 
    (define/public (get-color) 'red)))

(define spots+stripes-trait
  (trait-sum
   (trait-exclude (trait-alias spots-trait
                               get-color get-spots-color)
                  get-color)
   (trait-exclude (trait-alias stripes-trait
                               get-color get-stripes-color)
                  get-color)
   (trait
     (inherit get-spots-color get-stripes-color)
     (define/public (get-color)
       .... (get-spots-color) .... (get-stripes-color) ....))))
]

@; 13.9 类合约-------------------------------------------------------
@(class-eval '(require racket/contract))

@section[#:tag "Class-Contracts"]{类合约}

由于类是值，它们可以跨越合约边界，我们可能希望用合约保护给定类的一部分。为此，使用@racket[class/c]表。@racket[class/c]表具有许多子表，其描述关于字段和方法两种类型的合约：有些通过实例化对象影响使用，有些影响子类。

@; 13.9.1 外部类合约--------------------------------------------------------
@subsection[#:tag "External-Class-Contracts"]{外部类合约}

在最简单的表中，@racket[class/c]保护从合约类实例化的对象的公共字段和方法。还有一种@racket[object/c]表，可用于类似地保护特定对象的公共字段和方法。获取@racket[animal%]的以下定义，它使用公共字段作为其@racket[size]属性：

@racketblock[
(define animal%
  (class object% 
    (super-new)
    (field [size 10])
    (define/public (eat food)
      (set! size (+ size (get-field size food))))))]

对于任何实例化的@racket[animal%]，访问@racket[size]字段应该返回一个正数。另外，如果设置了@racket[size]字段，则应该分配一个正数。最后，@racket[eat]方法应该接收一个参数，它是一个包含一个正数的@racket[size]字段的对象。为了确保这些条件，我们将用适当的合约定义@racket[animal%]类：

@racketblock[
(define positive/c (and/c number? positive?))
(define edible/c (object/c (field [size positive/c])))
(define/contract animal%
  (class/c (field [size positive/c])
           [eat (->m edible/c void?)])
  (class object% 
    (super-new)
    (field [size 10])
    (define/public (eat food)
      (set! size (+ size (get-field size food))))))]

@interaction-eval[
#:eval class-eval
(begin
  (define positive/c
    (flat-named-contract 'positive/c (and/c number? positive?)))
  (define edible/c (object/c (field [size positive/c])))
  (define/contract animal%
    (class/c (field [size positive/c])
             [eat (->m edible/c void?)])
    (class object% 
      (super-new)
      (field [size 10])
      (define/public (eat food)
        (set! size (+ size (get-field size food)))))))]

这里我们使用@racket[->m]来描述@racket[eat]的行为，因为我们不需要描述这个@racket[this]参数的任何要求。既然我们有我们的合约类，就可以看出对@racket[size]和@racket[eat]的合约都是强制执行的：

@interaction[
#:eval class-eval
(define bob (new animal%))
(set-field! size bob 3)
(get-field size bob)
(set-field! size bob 'large)
(define richie (new animal%))
(send bob eat richie)
(get-field size bob)
(define rock (new object%))
(send bob eat rock)
(define giant (new (class object% (super-new) (field [size 'large]))))
(send bob eat giant)]

对于外部类合同有两个重要的警告。首先，当动态分派的目标是合约类的方法实施时，只有在合同边界内才实施外部方法合同。重写该实现，从而改变动态分派的目标，将意味着不再为客户机强制执行该合约，因为访问该方法不再越过合约边界。与外部方法合约不同，外部字段合约对于子类的客户机总是强制执行，因为字段不能被覆盖或屏蔽。

第二，这些合约不以任何方式限制@racket[animal%]的子类。被子类继承和使用的字段和方法不被这些合约检查，并且通过@racket[super]对基类方法的使用也不检查。下面的示例说明了两个警告：

@def+int[
#:eval class-eval
(define large-animal%
  (class animal%
    (super-new)
    (inherit-field size)
    (set! size 'large)
    (define/override (eat food)
      (display "Nom nom nom") (newline))))
(define elephant (new large-animal%))
(send elephant eat (new object%))
(get-field size elephant)]

@; 13.9.2 内部类合约----------------------------------------------------
@subsection[#:tag "Internal-Class-Contracts"]{内部类合约}

注意，从@racket[elephant]对象检索@racket[size]字段归咎于@racket[animal%]违反合约。这种归咎是正确的，但对@racket[animal%]类来说是不公平的，因为我们还没有提供一种保护自己免受子类攻击的方法。为此我们添加内部类合约，它提供指令给子类以指明它们如何访问和重写基类的特征。外部类和内部类合约之间的区别在于是否允许类层次结构中较弱的合约，其不变性可能被子类内部破坏，但应通过实例化的对象强制用于外部使用。

作为可用的保护类型的简单示例，我们提供了一个针对@racket[animal%]类的示例，它使用所有适用的表：

@racketblock[
(class/c (field [size positive/c])
         (inherit-field [size positive/c])
         [eat (->m edible/c void?)]
         (inherit [eat (->m edible/c void?)])
         (super [eat (->m edible/c void?)])
         (override [eat (->m edible/c void?)]))]

这个类合约不仅确保@racket[animal%]类的对象像以前一样受到保护，而且确保@racket[animal%]类的子类只在@racket[size]字段中存储适当的值，并适当地使用@racket[animal%]的@racket[size]实现。这些合约表只影响类层次结构中的使用，并且只影响跨合约边界的方法调用。

这意味着，@racket[inherit]（继承）只会影响到一个方法的子类使用直到子类重写方法，而@racket[override]只影响从基类进入方法的子类的重写实现。由于这些仅影响内部使用，所以在使用这些类的对象时，override表不会自动将子类插入到义务（obligations）中。此外，使用@racket[override]仅是说得通，因此只能用于没有beta样式增强的方法。下面的示例显示了这种差异：

@racketblock[
(define/contract sloppy-eater%
  (class/c [eat (->m edible/c edible/c)])
  (begin
    (define/contract glutton%
      (class/c (override [eat (->m edible/c void?)]))
      (class animal%
        (super-new)
        (inherit eat)
        (define/public (gulp food-list)
          (for ([f food-list])
            (eat f)))))
    (class glutton%
      (super-new)
      (inherit-field size)
      (define/override (eat f)
        (let ([food-size (get-field size f)])
          (set! size (/ food-size 2))
          (set-field! size f (/ food-size 2))
          f)))))]

@interaction-eval[
#:eval class-eval
(define/contract sloppy-eater%
  (class/c [eat (->m edible/c edible/c)])
  (begin
    (define/contract glutton%
      (class/c (override [eat (->m edible/c void?)]))
      (class animal%
        (super-new)
        (inherit eat)
        (define/public (gulp food-list)
          (for ([f food-list])
            (eat f)))))
    (class glutton%
      (super-new)
      (inherit-field size)
      (define/override (eat f)
        (let ([food-size (get-field size f)])
          (set! size (/ food-size 2))
          (set-field! size f (/ food-size 2))
          f)))))]

@interaction[
#:eval class-eval
(define pig (new sloppy-eater%))
(define slop1 (new animal%))
(define slop2 (new animal%))
(define slop3 (new animal%))
(send pig eat slop1)
(get-field size slop1)
(send pig gulp (list slop1 slop2 slop3))]

除了这里的内部类合约表所显示的之外，这里有beta样式可扩展的方法类似的表。@racket[inner]表描述了这个子类，它被要求从一个给定的方法扩展。@racket[augment]和@racket[augride]告诉子类，该给定的方法是一种被增强的方法，并且对子类方法的任何调用将动态分配到基类中相应的实现。这样的调用将根据给定的合约进行检查。这两种表的区别在于@racket[augment]的使用意味着子类可以增强给定的方法，而@racket[augride]的使用表示子类必须反而重写当前增强。

这意味着并不是所有的表都可以同时使用。只有@racket[override]、@racket[augment]和@racket[augride]中的一个表可用于一个给定的方法，而如果给定的方法已经完成，这些表没有一个可以使用。此外， 仅在@racket[augride]或@racket[override]可以指定时，@racket[super]可以被指定为一个给定的方法。同样，只有@racket[augment]或@racket[augride]可以指定时，@racket[inner]可以被指定。

@; ----------------------------------------------------------------------
@close-eval[class-eval]