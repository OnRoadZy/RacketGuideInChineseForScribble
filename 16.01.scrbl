;16.01.scrbl
;16.1 基于模式的宏
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/racket
          "guide-utils.rkt"
          (for-syntax racket/base))

@(define swap-eval (make-base-eval))

@title[#:tag "pattern-macros"]{基于模式的宏}

@deftech{基于模式的宏（pattern-based macro）}将任何与模式匹配的代码替换为使用与模式部分匹配的原始语法的一部分的扩展。

@; 16.1.1 define-syntax-rule----------------------------------------
@section{@racket[define-syntax-rule]}

创建宏的最简单方法是使用@racket[define-syntax-rule]：

@specform[(define-syntax-rule pattern template)]

作为一个运行的例子，考虑交换宏@racket[swap]，它将交换值存储在两个变量中。可以使用@racket[define-syntax-rule]实现如下：

@racketblock[
(define-syntax-rule (swap x y)
  (let ([tmp x])
    (set! x y)
    (set! y tmp)))
]

@racket[define-syntax-rule]表绑定一个与单个模式匹配的宏。模式必须总是以一个开放的括号开头，后面跟着一个标识符，这个标识符在这个例子中是@racket[swap]。在初始标识符之后，其它标识符是@deftech{宏模式变量（macro pattern variable）}，可以匹配宏使用中的任何内容。因此，这个宏匹配这个表@racket[(swap _form1 _form2)]给任何@racket[_form1]和@racket[_form2]。

在@racket[define-syntax-rule]中的模式之后是@deftech{摸板（template）}。模板用于替代与模式匹配的表，但模板中的模式变量的每个实例都替换为宏使用模式变量匹配的部分。例如，在

@racketblock[(swap first last)]

模式变量@racket[x]匹配@racket[first]及@racket[y]匹配@racket[last]，于是扩展是

@racketblock[
  (let ([tmp first])
    (set! first last)
    (set! last tmp))
]

@; 16.1.2 词法范围----------------------------------------
@section{词法范围}

假设我们使用@racket[swap]宏来交换名为@racket[tmp]和@racket[other]的变量：

@racketblock[
(let ([tmp 5]
      [other 6])
  (swap tmp other)
  (list tmp other))
]

上述表达式的结果应为@racketresult[(6 5)]。然而，这种@racket[swap]的使用的单纯扩展是

@racketblock[
(let ([tmp 5]
      [other 6])
  (swap tmp other)
  (list tmp other))
]

其结果是@racketresult[(5 6)]。问题在于，这个单纯的扩展混淆了上下文中的@racket[tmp]，那里@racket[swap]与宏摸板中的@racket[tmp]被使用。

Racket不会为了@racket[swap]的上述使用生成单纯的扩展。相反，它会生成以下内容

@racketblock[
(let ([tmp 5]
      [other 6])
  (let ([tmp_1 tmp])
    (set! tmp other)
    (set! other tmp_1))
  (list tmp other))
]

正确的结果在@racketresult[(6 5)]。同样，在示例中

@racketblock[
(let ([set! 5]
      [other 6])
  (swap set! other)
  (list set! other))
]

其扩展是

@racketblock[
(let ([set!_1 5]
      [other 6])
  (let ([tmp_1 set!_1])
    (set! set!_1 other)
    (set! other tmp_1))
  (list set!_1 other))
]

因此局部@racket[set!]绑定不会干扰宏模板引入的赋值。

换句话说，Racket的基于模式的宏自动维护词法范围，所以宏的实现者可以思考宏中的变量引用以及在同样的途径中作为函数和函数调用的宏使用。

@; 16.1.3 define-syntax和syntax-rules----------------------------------------
@section{@racket[define-syntax]和@racket[syntax-rules]}

@racket[define-syntax-rule]表绑定一个与单一模式匹配的宏，但Racket的宏系统支持从同一标识符开始匹配多个模式的转换器。要编写这样的宏，程序员必须使用更通用的@racket[define-syntax]表以及@racket[syntax-rules]转换器表：

@specform[#:literals (syntax-rules)
          (define-syntax id
            (syntax-rules (literal-id ...)
              [pattern template]
              ...))]

例如，假设我们希望一个@racket[rotate]宏将@racket[swap]概括为两个或三个标识符，因此

@racketblock[
(let ([red 1] [green 2] [blue 3])
  (rotate red green)      (code:comment @#,t{swaps})
  (rotate red green blue) (code:comment @#,t{rotates left})
  (list red green blue))
]

生成@racketresult[(1 3 2)]。我们可以使用@racket[syntax-rules]实现 @racket[rotate]：

@racketblock[
(define-syntax rotate
  (syntax-rules ()
    [(rotate a b) (swap a b)]
    [(rotate a b c) (begin
                     (swap a b)
                     (swap b c))]))
]

表达式@racket[(rotate red green)]与@racket[syntax-rules]表中的第一个模式相匹配，因此扩展到@racket[(swap red
green)]。表达式@racket[(rotate red green blue)]与第二个模式匹配，所以它扩展到@racket[(begin (swap red green) (swap green
blue))]。

@; 16.1.4 匹配序列------------------------------------------------
@section{匹配序列}

一个更好的@racket[rotate]宏将允许任意数量的标识符，而不是只有两个或三个标识符。匹配任何数量的标识符的@racket[rotate]使用，我们需要一个模式表，它有点像克林闭包（Kleene star）。在一个Racket宏模式中，一个闭包（star）被写成@racket[...]。

为了用@racket[...]实现@racket[rotate]，我们需要一个基元（base case）来处理单个标识符，以及一个归纳案例以处理多个标识符：

@racketblock[
(define-syntax rotate
  (syntax-rules ()
    [(rotate a) (void)]
    [(rotate a b c ...) (begin
                          (swap a b)
                          (rotate b c ...))]))
]

当在一种模式中像@racket[c]这样的模式变量被@racket[...]跟着的时候，它在模板中必须也被@racket[...]跟着。模式变量有效地匹配一个零序列或多个表，并在模板中以相同的顺序被替换。

到目前为止，@racket[rotate]的两种版本都有点效率低下，因为成对交换总是将第一个变量的值移动到序列中的每个变量，直到达到最后一个变量为止。更有效的@racket[rotate]将第一个值直接移动到最后一个变量。我们可以用@racket[...]模式使用辅助宏去实现更有效的变体：

@racketblock[
(define-syntax rotate
  (syntax-rules ()
    [(rotate a c ...)
     (shift-to (c ... a) (a c ...))]))

(define-syntax shift-to
  (syntax-rules ()
    [(shift-to (from0 from ...) (to0 to ...))
     (let ([tmp from0])
       (set! to from) ...
       (set! to0 tmp))]))
]

在@racket[shift-to]宏里，在模板里的@racket[...]后面跟着@racket[(set! to from)]，它导致@racket[(set! to from)]表达式在@racket[to]和@racket[from]序列中与必须使用的每个标识符匹配被复制一样多次。（@racket[to]和@racket[from]匹配的数量必须相同，否则宏扩展就会有一个错误的失败。）

@; 16.1.5 标识符宏-----------------------------------------------------
@section{标识符宏}

根据我们的宏定义，@racket[swap]或@racket[rotate]标识符必须在开括号之后使用，否则会报告语法错误：

@interaction-eval[#:eval swap-eval (define-syntax swap (syntax-rules ()))]

@interaction[#:eval swap-eval (+ swap 3)]

@deftech{标识符宏（identifier macro）}是一个模式匹配宏，当它被自己使用时不使用括号。例如，我们可以定义@racket[val]为一个标识符宏，扩展到@racket[(get-val)]，所以@racket[(+ val 3)]将扩展到@racket[(+ (get-val) 3)]。

@interaction-eval[#:eval swap-eval (require (for-syntax racket/base))]
@(define-syntax (with-syntax-as-syntax stx)
   (syntax-case stx ()
     [(_ e)
      (with-syntax ([s (datum->syntax #'e 'syntax)])
        #'(let-syntax ([s (make-element-id-transformer
                           (lambda (stx)
                             #'@racket[syntax]))]) ;print as syntax not #'
            e))]))

@(with-syntax-as-syntax
  @interaction[#:eval swap-eval
               (define-syntax val
                 (lambda (stx)
                   (syntax-case stx ()
                     [val (identifier? (syntax val)) (syntax (get-val))])))
               (define-values (get-val put-val!)
                 (let ([private-val 0])
                   (values (lambda () private-val)
                           (lambda (v) (set! private-val v)))))
               val
               (+ val 3)])

@racket[val]宏使用@racket[syntax-case]，它可以定义更强大的宏，并在《@secref["syntax-case"]》中讲解。现在，知道定义宏是必要的，在@racket[lambda]中使用了@racket[syntax-case]，它的模板必须用显式@racket[syntax]构造器包装。最后，@racket[syntax-case]子句可以指定模式后面的附加保护条件。

我们的@racket[val]宏使用@racket[identifier?]条件确保在括号中@racket[val]@emph{不能（must not）}使用。相反，宏引一个发语法错误：

@interaction[#:eval swap-eval
             (val)]

@; 16.1.6 set!转化器----------------------------------------
@section{@racket[set!]转化器}

使用上面的@racket[val]宏，我们仍然必须调用@racket[put-val!]更改存储值。然而，直接在@racket[val]上使用@racket[set!]会更方便。当@racket[val]用于@racket[set!]时借助宏，我们用@racket[make-set!-transformer]创建一个@tech[#:doc '(lib "scribblings/reference/reference.scrbl")]{赋值转换器（assignment transformer）}。我们还必须声明set!作为syntax-case文本列表中的文字。

@(with-syntax-as-syntax
  @interaction[#:eval swap-eval
               (define-syntax val2
                 (make-set!-transformer
                  (lambda (stx)
                    (syntax-case stx (set!)
                      [val2 (identifier? (syntax val2)) (syntax (get-val))]
                      [(set! val2 e) (syntax (put-val! e))]))))
               val2
               (+ val2 3)
               (set! val2 10)
               val2])

@; 16.1.7 宏生成宏----------------------------------------
@section{宏生成宏}

假设我们有许多标识符像@racket[val]和@racket[val2]，我们想重定向给访问器和突变函数像@racket[get-val]和@racket[put-val!]。我们希望可以只写：

@racketblock[
(define-get/put-id val get-val put-val!)
]

自然地，我们可以实现@racket[define-get/put-id]为一个宏：

@(with-syntax-as-syntax
  @interaction[#:eval swap-eval
 (define-syntax-rule (define-get/put-id id get put!)
   (define-syntax id
     (make-set!-transformer
      (lambda (stx)
        (syntax-case stx (set!)
          [id (identifier? (syntax id)) (syntax (get))]
          [(set! id e) (syntax (put! e))])))))
 (define-get/put-id val3 get-val put-val!)
 (set! val3 11)
 val3])

@racket[define-get/put-id]宏就是是一个@deftech{宏生成宏（macro-generating macro）}。

@; 16.1.8 扩展的例子：函数的引用调用----------------------------------------
@section[#:tag "pattern-macro-example"]{扩展的例子：函数的引用调用（Call-by-Reference）}

我们可以使用模式匹配宏将一个表添加到Racket中，以定义@deftech{引用调用函数（call-by-reference function）}的一阶调用。当通过参考函数本体转变它的正式参数，这个转变应用到变量，它在对函数的调用中作为一个实参提供。

例如，如果@racket[define-cbr]类似于@racket[define]，除了定义应用调用函数，那么

@racketblock[
(define-cbr (f a b)
  (swap a b))

(let ([x 1] [y 2])
  (f x y)
  (list x y))
]

生成@racketresult[(2 1)]。

我们会通过有函数调用支持的对参数的访问器和转换器执行参考函数，而不是直接提供参数值。特别是，对于上面的函数@racket[f]，我们将生成

@racketblock[
(define (do-f get-a get-b put-a! put-b!)
  (define-get/put-id a get-a put-a!)
  (define-get/put-id b get-b put-b!)
  (swap a b))
]

并将函数调用@racket[(f x y)]重定向到

@racketblock[
(do-f (lambda () x)
      (lambda () y)
      (lambda (v) (set! x v))
      (lambda (v) (set! y v)))
]

显然，然后@racket[define-cbr]是宏生成宏，绑定@racket[f]到一个宏，它扩展到@racket[do-f]的一个调用。即@racket[(define-cbr (f a b) (swap a b))]需要生成的定义

@racketblock[
(define-syntax f
  (syntax-rules ()
    [(id actual ...)
     (do-f (lambda () actual)
           ...
           (lambda (v)
             (set! actual v))
           ...)]))
]

同时，@racket[define-cbr]需要使用@racket[f]本体去定义@racket[do-f]，第二部分是略微更复杂些，所以我们延迟它的大部分给一个@racket[define-for-cbr]辅助模块，它可以让我们足够简单地编写@racket[define-cbr]：

@racketblock[
(define-syntax-rule (define-cbr (id arg ...) body)
  (begin
    (define-syntax id
      (syntax-rules ()
        [(id actual (... ...))
         (do-f (lambda () actual) 
               (... ...)
               (lambda (v) 
                 (set! actual v))
               (... ...))]))
    (define-for-cbr do-f (arg ...)
      () (code:comment @#,t{explained below...})
      body)))
]

我们剩下的任务是定义@racket[define-for-cbr]以便它转换

@racketblock[
(define-for-cbr do-f (a b) () (swap a b))
]

到上边的这个函数定义@racket[do-f]两个功能定义。大部分的工作是生成一个@racket[define-get/put-id]声明给每个参数，@racket[a]和@racket[b]，以及把他们放在本体之前。通常，对于在模式和模板中的@racket[...]那是很容易的任务，但这次这里有一个捕获：我们需要既生成这个名字@racket[get-a]和@racket[put-a!]也要生成@racket[get-b]和@racket[put-b!]，这个模式语言没有办法提供基于现有标识符的综合标识符。

事实证明，词法范围给了我们解决这个问题的方法。诀窍是为函数中的每个参数迭代一次对@racket[define-for-cbr]的扩展，这就是为什么@racket[define-for-cbr]开始用一个在参数列表后面明显无效的@racket[()]的原因。除了要处理的参数外，我们还需要跟踪迄今为止所看到的所有参数以及为每个生成的@racket[get]和@racket[put]名称。在处理完所有的标识符之后，我们就拥有了所有需要的名称。

这里是@racket[define-for-cbr]的定义：

@racketblock[
(define-syntax define-for-cbr
  (syntax-rules ()
    [(define-for-cbr do-f (id0 id ...)
       (gens ...) body)
     (define-for-cbr do-f (id ...) 
       (gens ... (id0 get put)) body)]
    [(define-for-cbr do-f ()
       ((id get put) ...) body)
     (define (do-f get ... put ...)
       (define-get/put-id id get put) ...
       body)]))
]

一步一步，展开如下：

@racketblock[
(define-for-cbr do-f (a b)
  () (swap a b))
(unsyntax @tt{=>}) (define-for-cbr do-f (b)
     ([a get_1 put_1]) (swap a b))
(unsyntax @tt{=>}) (define-for-cbr do-f ()
     ([a get_1 put_1] [b get_2 put_2]) (swap a b))
(unsyntax @tt{=>}) (define (do-f get_1 get_2 put_1 put_2)
     (define-get/put-id a get_1 put_1)
     (define-get/put-id b get_2 put_2)
     (swap a b))
]

在@racket[get_1]、@racket[get_2]、@racket[put_1]和@racket[put_2]上的“下标（subscript）”通过宏扩展插入到保留词法范围，因为@racket[get]被@racket[define-for-cbr]的每一次迭代生成不应捆绑被不同的迭代生成的@racket[get]。换句话说，我们本质上欺骗这个宏扩展以生成的我们新的名字，但技术显示了一些与自动词法范围的宏模式的神奇力量。

最后表达式最终扩展成

@racketblock[
(define (do-f get_1 get_2 put_1 put_2)
  (let ([tmp (get_1)])
    (put_1 (get_2))
    (put_2 tmp)))
]

它实现了名称调用（call-by-name）函数@racket[f]。

接下来，总结一下，我们可以只用三个基于模式的宏添加引用调用（call-by-reference）函数到Racket中：@racket[define-cbr]、@racket[define-for-cbr]和@racket[define-get/put-id]。

@; -----------------------------------------------------------------
@close-eval[swap-eval]