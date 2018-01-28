;05.07.scrbl
;5.7 预制结构类型
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          "guide-utils.rkt"
          (for-label racket/dict racket/serialize))

@(define posn-eval (make-base-eval))

@title[#:tag "prefab-struct"]{预制结构类型}

虽然@tech{transparent}结构类型以显示内容的方式打印，但结构的打印形式不能用于表达式中以获得结构，不像数字、字符串、符号或列表的打印形式。

@deftech{预制（prefab）}（“被预先制造”）结构类型是内置的类型，是已知的Racket打印机和表达式阅读器。有无限多这样的类型存在，他们索引是通过名字、字段计数、超类型以及其它细节。一个预制结构的打印形式类似于一个矢量，但它以@litchar{#s}开始而不是以@litchar{#}开始，而且打印表的第一个元素是预制结构类型的名称。

下面的示例显示具有一个字段的@racketidfont{sprout}预置结构类型的实例。第一个实例具有字段值@racket['bean]，第二个实例具有字段值@racket['alfalfa]：

@interaction[
'#s(sprout bean)
'#s(sprout alfalfa)
]

像数字和字符串一样，预置结构是“自引用”，所以上面的引号是可选的：

@interaction[
#s(sprout bean)
]

当你随@racket[struct]使用@racket[#:prefab]关键字，而不是生成一个新的结构类型，你获得与现有的预制结构类型的绑定操作：

@interaction[
#:eval posn-eval
(define lunch '#s(sprout bean))
(struct sprout (kind) #:prefab)
(sprout? lunch)
(sprout-kind lunch)
(sprout 'garlic)
]

上面的字段名称@racketidfont{kind}对查找预置结构类型无关紧要，仅名称@racketidfont{sprout}和字段的数量是紧要的。同时，具有三个字段的预制结构类型@racketidfont{sprout}是一种不同于单个字段的结构类型：

@interaction[
#:eval posn-eval
(sprout? #s(sprout bean #f 17))
(code:line (struct sprout (kind yummy? count) #:prefab) (code:comment @#,t{redefine}))
(sprout? #s(sprout bean #f 17))
(sprout? lunch)
]

预制结构类型可以有另一种预制结构类型作为它的超类型，它具有可变的字段，并可以有自动字段。这些维度中的任何变化都对应于不同的预置结构类型，结构类型的名称的打印形式编码所有相关的细节。

@interaction[
(struct building (rooms [location #:mutable]) #:prefab)
(struct house building ([occupied #:auto]) #:prefab
  #:auto-value 'no)
(house 5 'factory)
]

每个@tech{预制（prefab）}结构类型都是@tech{透明（transparent）}的——但甚至比@tech{透明（transparent）}类型更抽象，因为可以创建实例而不必访问特定的结构类型声明或现有示例。总体而言，结构类型的不同选项提供了更抽象到更方便的各种可能性：

@itemize[

@item{@tech{不透明的（Opaque）}（默认）：没有访问结构类型声明，就不能检查或创造实例。正如下一节所讨论的，@tech{构造函数守护程序（constructor guards）}和@tech{属性（properties）}可以附加到结构类型上，以进一步保护或专门化其实例的行为。}
 @item{@tech{透明的（Transparent）}：任何人都可以检查或创建一个没有访问结构类型声明的实例，这意味着值打印机可以显示实例的内容。然而，所有实例创建都通过一个tech{构造函数守护程序（constructor guards）}守护程序，这样可以控制实例的内容，并且实例的行为可以通过@tech{属性（properties）}进行特例化。由于结构类型是由其定义生成的，所以实例不能简单地通过结构类型的名称来生成，因此不能由表达式读取器自动生成。}

@item{@tech{预制（Prefab）}：任何人都可以在任何时候检查或创建实例，而不必事先访问结构类型声明或实例。因此，表达式读取器可以直接生成实例。实例不能具有@tech{构造函数守护程序（constructor guards）}或@tech{属性（properties）}。

由于表达式读取器可以生成@tech{预制（prefab）}实例，所以在方便序列化比抽象更重要时它们是有用的。然而，@tech{不透明（Opaque）}和@tech{透明（transparent）}的结构也可以被@tech{序列化（serialization）}，如果他们被@racket[serializable-struct]定义，其描述见《@secref["serialization"]》。}]

@close-eval[posn-eval]