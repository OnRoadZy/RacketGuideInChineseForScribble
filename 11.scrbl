;11.scrbl
;11 迭代和推导
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "for"]{迭代和推导}

用于语法形式的@racket[for]家族支持对@defterm{序列（sequences）}进行迭代。列表、向量、字符串、字节字符串、输入端口和散列表都可以用作序列，像@racket[in-range]的构造函数可以提供更多类型的序列。

@racket[for]的变种以不同的方式累积迭代结果，但它们都具有相同的语法形态。 现在简化了，for的语法是

@specform[
(for ([id sequence-expr] ...)
  body ...+)
]{}

一个@racket[for]循环遍历由@racket[_sequence-expr]生成的序列。 对于序列的每个元素，@racket[for]将元素绑定到@racket[_id]，然后副作用求值@racket[_body]。

@examples[
(for ([i '(1 2 3)])
  (display i))
(for ([i "abc"])
  (printf "~a..." i))
(for ([i 4])
  (display i))
]

@racket[for]的@racket[for/list]变体更像Racket。它将@racket[_body]结果累积到一个列表中，而不是仅仅副作用求值@racket[_body]。 在更多的技术术语中，@racket[for/list]实现了一个@defterm{列表理解（list
comprehension）}。

@examples[
(for/list ([i '(1 2 3)])
  (* i i))
(for/list ([i "abc"])
  i)
(for/list ([i 4])
  i)
]

@racket[for]的完整语法可容纳多个序列并行迭代，@racket[for*]变体可以嵌套迭代，而不是并行运行。 @racket[for]和@racket[for*]的更多变体以不同的方式产生积累@racket[_body]结果。 在所有这些变体中，包含迭代的判断可以同时包含绑定。

不过，在@racket[for]的变化细节之前，最好是先查看生成有趣示例的序列生成器的类型。

@;----------------------------------------------------
@section[#:tag "sequences"]{序列构造}

@racket[in-range]函数生成数值序列，给定一个可选的起始数字（默认为@racket[0]），序列结束前的数字和一个可选的步长（默认为@racket[1]）。 直接使用非负整数@racket[_k]作为一个序列是对@racket[(in-range _k)]的简写。

@examples[
(for ([i 3])
  (display i))
(for ([i (in-range 3)])
  (display i))
(for ([i (in-range 1 4)])
  (display i))
(for ([i (in-range 1 4 2)])
  (display i))
(for ([i (in-range 4 1 -1)])
  (display i))
(for ([i (in-range 1 4 1/2)])
  (printf " ~a " i))
]

@racket[in-naturals]函数是相似的，除了起始数字必须是一个确切的非负整数（默认为@racket[0]），步长总是@racket[1]，没有上限。一个@racket[for]循环只使用@racket[in-naturals]将永远不会终止，除非正文表达引发异常或以其他方式退出。

@examples[
(for ([i (in-naturals)])
  (if (= i 10)
      (error "too much!")
      (display i)))
]

@racket[stop-before]函数和@racket[stop-after]函数构造一个给定序列和一个判断的一个新的序列。这个新序列就像这个给定的序列，但是在判断返回true的第一个元素之前或之后立即被截断。

@examples[
(for ([i (stop-before "abc def"
                      char-whitespace?)])
  (display i))
]

像@racket[in-list]、@racket[in-vector]和@racket[in-string]这样的序列构造器只是简单地使用列表（list）、向量（vector）和字符串（string）作为序列。和@racket[in-range]一样，这些构造器在给定错误类型的值时会引发异常，并且由于它们会避免运行时调度来确定序列类型，因此可以实现更高效的代码生成; 有关更多信息，请参阅《@secref["for-performance"]》。

@examples[
(for ([i (in-string "abc")])
  (display i))
(for ([i (in-string '(1 2 3))])
  (display i))
]

@; 11.2 for和for*-------------------------------------------------------
@section[#:tag "for-for*"]{@racket[for]和@racket[for*]}

@racket[for]的更完整的语法是

@specform/subs[
(for (clause ...)
  body ...+)
([clause [id sequence-expr]
         (code:line #:when boolean-expr)
         (code:line #:unless boolean-expr)])
]{}

当多个@racket[[_id _sequence-expr]]从句在一个@racket[for]表里提供时，相应的序列并行遍历：

@interaction[
(for ([i (in-range 1 4)]
      [chapter '("Intro" "Details" "Conclusion")])
  (printf "Chapter ~a. ~a\n" i chapter))
]

对于并行序列，@racket[for]表达式在任何序列结束时停止迭代。这种行为允许@racket[in-naturals]创造数值的无限序列，可用于索引：

@interaction[
(for ([i (in-naturals 1)]
      [chapter '("Intro" "Details" "Conclusion")])
  (printf "Chapter ~a. ~a\n" i chapter))
]

@racket[for*]表具有与 @racket[for]语法相同的语法，嵌套多个序列，而不是并行运行它们：

@interaction[
(for* ([book '("Guide" "Reference")]
       [chapter '("Intro" "Details" "Conclusion")])
  (printf "~a ~a\n" book chapter))
]

因此，@racket[for*]是对嵌套@racket[for]的一个简写，以同样的方式@racket[let*]是一个@racket[let]嵌套的简写。

一个@racket[_clause]的@racket[#:when _boolean-expr]表是另一个简写。仅当@racket[_boolean-expr]产生一个真值时它允许@racket[_body]求值：

@interaction[
(for* ([book '("Guide" "Reference")]
       [chapter '("Intro" "Details" "Conclusion")]
       #:when (not (equal? chapter "Details")))
  (printf "~a ~a\n" book chapter))
]

一个带@racket[#:when]的@racket[_boolean-expr]可以适用于任何上述迭代绑定。在一个@racket[for]表里，仅仅如果在前面绑定的迭代测试是嵌套的时，这个范围是有意义的；因此，用@racket[#:when]隔离绑定是多重嵌套的，而不是平行的，甚至于用@racket[for]也一样。

@interaction[
(for ([book '("Guide" "Reference" "Notes")]
      #:when (not (equal? book "Notes"))
      [i (in-naturals 1)]
      [chapter '("Intro" "Details" "Conclusion" "Index")]
      #:when (not (equal? chapter "Index")))
  (printf "~a Chapter ~a. ~a\n" book i chapter))
]

一个@racket[#:unless]从句和一个@racket[#:when]从句是类似的，但仅当@racket[_boolean-expr]产生一个非值时@racket[_body]求值。

@; 11.3 for/list和for*/list-------------------------------------------------------
@section[#:tag "for/list-for*/list"]{@racket[for/list]和@racket[for*/list]}

@racket[for/list]表具有与@racket[for]相同的语法，它对 @racket[_body]求值以获取进入新构造列表的值：

@interaction[
(for/list ([i (in-naturals 1)]
           [chapter '("Intro" "Details" "Conclusion")])
  (string-append (number->string i) ". " chapter))
]

一个@racket[for-list]表的一个@racket[#:when]从句修剪这个结果列表连同@racket[_body]的求值：

@interaction[
(for/list ([i (in-naturals 1)]
           [chapter '("Intro" "Details" "Conclusion")]
           #:when (odd? i))
  chapter)
]

使用@racket[for/list]的@racket[#:when]修剪行为是比@racket[for]更有用的。而对@racket[for]来说扁平的@racket[when]表通常是满足需要的，一个@racket[for/list]里的一个@racket[when]表达表会导致结果列表包含 @|void-const|以代替省略列表元素。

@racket[for*/list]表类似于@racket[for*]，嵌套多个迭代：
 

@interaction[
(for*/list ([book '("Guide" "Ref.")]
            [chapter '("Intro" "Details")])
  (string-append book " " chapter))
]

一个@racket[for*/list]表与嵌套@racket[for/list]表不太一样。嵌套@racket[for/list]将生成一个列表的列表，而不是一个扁平列表。非常像@racket[#:when]，那么，@racket[for*/list]的嵌套比@racket[for*]的嵌套更有用。

@; 11.4 for/vector和for*/vector-------------------------------------
@section[#:tag "for/vector-for*/vector"]{@racket[for/vector]和@racket[for*/vector]}

@racket[for/vector]表可以使用与@racket[for/list]表相同的语法，但是对@racket[_body]的求值进入一个新构造的向量而不是列表：

@interaction[
(for/vector ([i (in-naturals 1)]
             [chapter '("Intro" "Details" "Conclusion")])
  (string-append (number->string i) ". " chapter))
]

@racket[for*/vector]表的行为类似，但迭代嵌套和@racket[for*]一样。
 @racket[for/vector]和@racket[for*/vector]表也允许构造向量的长度，在预先提供的情况下。由此产生的迭代可以比@racket[for/vector]或@racket[for*/vector]更有效地执行：
 
@interaction[
(let ([chapters '("Intro" "Details" "Conclusion")])
  (for/vector #:length (length chapters) ([i (in-naturals 1)]
                                          [chapter chapters])
    (string-append (number->string i) ". " chapter)))
]

如果提供了一个长度，当向量（vector）被填充或被请求完成时迭代停止，而无论哪个先来。如果所提供的长度超过请求的迭代次数，则向量中的剩余槽被初始化为@racket[make-vector]的缺省参数。

@; 11.5 for/and和for/or--------------------------------------------------------
@section[#:tag "for/and-for/or"]{@racket[for/and]和@racket[for/or]}

@racket[for/and]表用@racket[and]组合迭代结果，一旦遇到@racket[#f]就停止：

@interaction[
(for/and ([chapter '("Intro" "Details" "Conclusion")])
  (equal? chapter "Intro"))
]

@racket[for/or]表用@racket[or]组合迭代结果，一旦遇到真（true）值立即停止：

@interaction[
(for/or ([chapter '("Intro" "Details" "Conclusion")])
  (equal? chapter "Intro"))
]

与通常一样，@racket[for*/and]和@racket[for*/or]表提供与嵌套迭代相同的功能。

@; 11.6 for/first和for/last---------------------------------------------------------
@section[#:tag "for/first-for/last"]{@racket[for/first]和@racket[for/last]}

@racket[for/first]表返回第一次对@racket[_body]进行求值的结果，跳过了进一步的迭代。这个带有一个@racket[#:when]从句的表是最非常有用的。

@interaction[
(for/first ([chapter '("Intro" "Details" "Conclusion" "Index")]
            #:when (not (equal? chapter "Intro")))
  chapter)
]

如@racket[_body]求值进行零次，那么结果是@racket[#f]。

@racket[for/last]表运行所有迭代，返回最后一次迭代的值（或如果没有迭代运行返回@racket[#f]）：

@interaction[
(for/last ([chapter '("Intro" "Details" "Conclusion" "Index")]
            #:when (not (equal? chapter "Index")))
  chapter)
]

通常，@racket[for*/first]和@racket[for*/last]表提供和嵌套迭代相同的工具：

@interaction[
(for*/first ([book '("Guide" "Reference")]
             [chapter '("Intro" "Details" "Conclusion" "Index")]
             #:when (not (equal? chapter "Intro")))
  (list book chapter))

(for*/last ([book '("Guide" "Reference")]
            [chapter '("Intro" "Details" "Conclusion" "Index")]
            #:when (not (equal? chapter "Index")))
  (list book chapter))
]

@; 11.7 for/fold和for*fold--------------------------------------------------------
@section[#:tag "for/fold"]{@racket[for/fold]和@racket[for*/fold]}

@racket[for/fold]表是合并迭代结果的一种非常通用的方法。它的语法与原来的@racket[for]语法略有不同，因为必须在开始时声明累积变量：

@racketblock[
(for/fold ([_accum-id _init-expr] ...)
          (_clause ...)
  _body ...+)
]

在简单的情况下，仅提供一个 @racket[[_accum-id _init-expr]]，那么@racket[for/fold]的结果是@racket[_accum-id]的最终值，并启动了@racket[_init-expr]的值。在@racket[_clause]和@racket[_body]、@racket[_accum-id]可参照获得其当前值，并且最后的@racket[_body]为下一次迭代的提供@racket[_accum-id]值。

@examples[
(for/fold ([len 0])
          ([chapter '("Intro" "Conclusion")])
  (+ len (string-length chapter)))
(for/fold ([prev #f])
          ([i (in-naturals 1)]
           [chapter '("Intro" "Details" "Details" "Conclusion")]
           #:when (not (equal? chapter prev)))
  (printf "~a. ~a\n" i chapter)
  chapter)
]

当多个@racket[_accum-id]被指定，那么最后的@racket[_body]必须产生多值，每一个对应@racket[_accum-id]。@racket[for/fold]的表达式本身给结果产生多值。

@examples[
(for/fold ([prev #f]
           [counter 1])
          ([chapter '("Intro" "Details" "Details" "Conclusion")]
           #:when (not (equal? chapter prev)))
  (printf "~a. ~a\n" counter chapter)
  (values chapter
          (add1 counter)))
]

@; 11.8 多值序列----------------------------------------------------------------
@section[#:tag "multiple-valued-sequences"]{多值序列}

同样，一个函数或表达式可以生成多个值，序列的单个迭代可以生成多个元素。例如，作为一个序列的哈希表生成两个迭代的两个值：一个键和一个值。

同样方式，@racket[let-values]将多个结果绑定到多个标识符，@racket[for]能将多个序列元素绑定到多个迭代标识符：

@interaction[
(for ([(k v) #hash(("apple" . 1) ("banana" . 3))])
  (printf "~a count: ~a\n" k v))
]

这种对多值绑定的扩展对所有@racket[for]变体都适用。例如，@racket[for*/list]嵌套迭代，构建一个列表，也可以处理多值序列：

@interaction[
(for*/list ([(k v) #hash(("apple" . 1) ("banana" . 3))]
            [(i) (in-range v)])
  k)
]

@; 11.9 打断迭代-------------------------------------------------------
@section[#:tag "breaking-an-iteration"]{打断迭代}

一个更完整的@racket[for]的语法是

@specform/subs[
(for (clause ...)
  body-or-break ... body)
([clause [id sequence-expr]
         (code:line #:when boolean-expr)
         (code:line #:unless boolean-expr)
         break]
 [body-or-break body break]
 [break  (code:line #:break boolean-expr)
         (code:line #:final boolean-expr)])
]{}

那是，一个@racket[#:break]或@racket[#:final]从句可以包括绑定从句和body之间的迭代。在绑定从句之间，当它的@racket[_boolean-expr]为真（true）时，@racket[#:break]像@racket[#:unless]，在@racket[for]之间的所有序列停止。处在@racket[_body]内，除了当@racket[_boolean-expr]是真时，@racket[#:break]对序列有一样的效果，并且它也阻止随后的@racket[_body]从当前迭代的求值。

例如，当在有效跳跃后的序列以及主体之间使用@racket[#:unless]，

@interaction[
(for ([book '("Guide" "Story" "Reference")]
      #:unless (equal? book "Story")
      [chapter '("Intro" "Details" "Conclusion")])
  (printf "~a ~a\n" book chapter))
]

使用@racket[#:break]从句致使整个@racket[for]迭代终止：

@interaction[
(for ([book '("Guide" "Story" "Reference")]
      #:break (equal? book "Story")
      [chapter '("Intro" "Details" "Conclusion")])
  (printf "~a ~a\n" book chapter))
(for* ([book '("Guide" "Story" "Reference")]
       [chapter '("Intro" "Details" "Conclusion")])
  #:break (and (equal? book "Story")
               (equal? chapter "Conclusion"))
  (printf "~a ~a\n" book chapter))
]

一个@racket[#:final]从句类似于@racket[#:break]，但它不立即终止迭代。相反，它最多地允许为每一个序列和最多再一个 @racket[_body]的求值绘制再一个元素。

@interaction[
(for* ([book '("Guide" "Story" "Reference")]
       [chapter '("Intro" "Details" "Conclusion")])
  #:final (and (equal? book "Story")
               (equal? chapter "Conclusion"))
  (printf "~a ~a\n" book chapter))
(for ([book '("Guide" "Story" "Reference")]
      #:final (equal? book "Story")
      [chapter '("Intro" "Details" "Conclusion")])
  (printf "~a ~a\n" book chapter))
]

@; 11.10 迭代性能-------------------------------------------------------
@section[#:tag "for-performance"]{迭代性能}

理想情况下，作为递归函数调用，一个@racket[for]迭代的运行速度应该与手工编写的循环一样快。然而，手写循环通常是针对特定类型的数据，如列表。在这种情况下，手写循环直接使用选择器，比如@racket[car]和@racket[cdr]，而不是处理所有序列表并分派给合适的迭代器。

当足够的信息反复提供给迭代序列时，@racket[for]表可以提供手写循环的性能。具体来说，从句应具有下列@racket[_fast-clause]表之一：

@racketgrammar[
fast-clause [id fast-seq]
            [(id) fast-seq]
            [(id id) fast-indexed-seq]
            [(id ...) fast-parallel-seq]
]

@racketgrammar[
#:literals [in-range in-naturals in-list in-vector in-string in-bytes in-value stop-before stop-after]
fast-seq (in-range expr)
         (in-range expr expr)
         (in-range expr expr expr)
         (in-naturals)
         (in-naturals expr)
         (in-list expr)
         (in-vector expr)
         (in-string expr)
         (in-bytes expr)
         (in-value expr)
         (stop-before fast-seq predicate-expr)
         (stop-after fast-seq predicate-expr)
]

@racketgrammar[
#:literals [in-indexed stop-before stop-after]
fast-indexed-seq (in-indexed fast-seq)
                  (stop-before fast-indexed-seq predicate-expr)
                  (stop-after fast-indexed-seq predicate-expr)
]

@racketgrammar[
#:literals [in-parallel stop-before stop-after]
fast-parallel-seq (in-parallel fast-seq ...)
                  (stop-before fast-parallel-seq predicate-expr)
                  (stop-after fast-parallel-seq predicate-expr)
]

@examples[
(time (for ([i (in-range 100000)])
        (for ([elem (in-list '(a b c d e f g h))]) (code:comment @#,elem{快})
          (void))))
(time (for ([i (in-range 100000)])
        (for ([elem '(a b c d e f g h)])           (code:comment @#,elem{较慢})
          (void))))
(time (let ([seq (in-list '(a b c d e f g h))])
        (for ([i (in-range 100000)])
          (for ([elem seq])                        (code:comment @#,elem{较慢})
            (void)))))
]

上面的语法是不完整的，因为提供良好性能的语法模式集是可扩展的，就像序列值集一样。序列构造器的文档应该说明直接使用@racket[for]从句（@racket[_clause]）的性能优势。
