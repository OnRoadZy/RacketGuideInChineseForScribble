;05.08.scrbl
;5.8 更多的结构选项
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/bnf
          "guide-utils.rkt"
          (for-label racket/dict racket/serialize))

@(define posn-eval (make-base-eval))

@title[#:tag "struct-options"]{更多的结构选项}

@racket[struct]的完整语法支持许多选项，无论是在结构类型级别，还是在单个字段的级别上：

@specform/subs[(struct struct-id maybe-super (field ...)
                       struct-option ...)
               ([maybe-super code:blank
                             super-id]
                [field field-id
                       [field-id field-option ...]])]

一个 @racket[_struct-option]总是以关键字开头：

@specspecsubform[#:mutable]{

会导致结构的所有字段是可变的，并给每个@racket[_field-id]产生一个@racketidfont{set-}@racket[_struct-id]@racketidfont{-}@racket[_field-id]@racketidfont{!}@deftech{设置方式（mutator）}，在结构类型的实例中设置对应字段的值。

@defexamples[(struct dot (x y) #:mutable)
                  (define d (dot 1 2))
                  (dot-x d)
                  (set-dot-x! d 10)
             (dot-x d)]

@racket[#:mutable]选项也可以被用来作为一个@racket[_field-option]，在这种情况下，它使个别字段可变。

@defexamples[
   (struct person (name [age #:mutable]))
   (define friend (person "Barney" 5))
   (set-person-age! friend 6)
   (set-person-name! friend "Mary")]}

@specspecsubform[(code:line #:transparent)]{

控制对结构实例的反射访问，如前面一节所讨论的《@secref["trans-struct"]》那样。}

@specspecsubform[(code:line #:inspector inspector-expr)]{

概括@racket[#:transparent]以支持更多的控制访问或反射操作。}

@specspecsubform[(code:line #:prefab)]{

访问内置结构类型，如前一节所讨论的《@secref["prefab-struct"]》那样。}

@specspecsubform[(code:line #:auto-value auto-expr)]{

指定了一个被用于所有结构类型的自动字段的值，这里一个自动字段被@racket[#:auto]字段选项表明。这个构造函数不接受给自动字段的参数。自动字段无疑是可变的（通过反射操作），但设置函数仅在@racket[#:mutable]也被指定的时候被绑定。

 @defexamples[
 (struct posn (x y [z #:auto])
   #:transparent
   #:auto-value 0)
 (posn 1 2)
 ]}

@specspecsubform[(code:line #:guard guard-expr)]{

指定在创建结构类型的实例时调用的构造@deftech{函数保护过程（constructor guard）}。在结构类型中，保护程序获取与非自动字段相同的参数，再加上一个实例化类型的名称（如果子类型被实例化，在这种情况下最好使用子类型的名称报告错误）。保护过程应该返回与给定值相同的值，减去名称参数。如果某个参数不可接受，或者可以转换一个参数，则保护过程可以引发异常。

 @defexamples[
 #:eval posn-eval
 (struct thing (name)
   #:transparent
   #:guard (lambda (name type-name)
             (cond
               [(string? name) name]
               [(symbol? name) (symbol->string name)]
               [else (error type-name 
                            "bad name: ~e" 
                            name)])))
 (thing "apple")
 (thing 'apple)
 (thing 1/2)
 ]

即使创建子类型实例，也会调用保护过程。在这种情况下，只有构造函数接受的字段被提供给保护过程（但是子类型的保护过程同时获得子类型添加的原始字段和现有字段）。

 @defexamples[
  #:eval posn-eval
  (struct person thing (age)
          #:transparent
          #:guard (lambda (name age type-name)
                    (if (negative? age)
                        (error type-name "bad age: ~e" age)
                        (values name age))))
  (person "John" 10)
  (person "Mary" -1)
  (person 10 10)]}

@specspecsubform[(code:line #:methods interface-expr [body ...])]{

关联与@defterm{通用接口（generic interface）}对应的结构类型的方法定义。例如，执行@racket[gen:dict]方法允许一个结构类型实例用作字典。执行@racket[gen:custom-write]方法允许定制如何@racket[显示（display）]结构类型的实例。

 @defexamples[
 (struct cake (candles)
   #:methods gen:custom-write
   [(define (write-proc cake port mode)
      (define n (cake-candles cake))
      (show "   ~a   ~n" n #\. port)
      (show " .-~a-. ~n" n #\| port)
      (show " | ~a | ~n" n #\space port)
      (show "---~a---~n" n #\- port))
    (define (show fmt n ch port)
      (fprintf port fmt (make-string n ch)))])
 (display (cake 5))]}

@specspecsubform[(code:line #:property prop-expr val-expr)]{

将@deftech{属性（property）}和值与结构类型相关联。例如，@racket[prop:procedure]属性允许一个结构实例作为函数使用；属性值决定当使用结构作为函数时如何执行。

 @defexamples[
 (struct greeter (name)
   #:property prop:procedure
   (lambda (self other)
     (string-append
      "Hi " other
      ", I'm " (greeter-name self))))
 (define joe-greet (greeter "Joe"))
 (greeter-name joe-greet)
 (joe-greet "Mary")
 (joe-greet "John")]}

@specspecsubform[(code:line #:super super-expr)]{

一种替代提供@racket[super-id]与@racket[struct-id]紧邻。代替这个结构类型的名字（它是一个表达式），@racket[super-expr]应该产生一种@tech{结构类型的描述符（structure type descriptor）}的值。对@racket[#:super]更高级形式是结构类型的描述符是值，所以他们可以通过程序。

@defexamples[
    #:eval posn-eval
    (define (raven-constructor super-type)
      (struct raven ()
              #:super super-type
              #:transparent
              #:property prop:procedure (lambda (self)
                                          'nevermore))
      raven)
    (let ([r ((raven-constructor struct:posn) 1 2)])
      (list r (r)))
    (let ([r ((raven-constructor struct:thing) "apple")])
      (list r (r)))]}

@close-eval[posn-eval]