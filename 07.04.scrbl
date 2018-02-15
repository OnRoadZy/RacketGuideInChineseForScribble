;07.04.scrbl
;7.4 合约：一个全面的例子
#lang scribble/doc

@(require scribble/manual
          scribble/core
          scribble/eval
          "utils.rkt"
          (only-in racket/list
                   argmax)
          (for-label racket/contract))

@title[#:tag "contracts-first"]{合约：一个全面的例子}

这部分发掘几种不同的特点，针对一个相同实例的合约：Racket的@racket[argmax]函数。根据它的Racket文档，函数接受一个过程@racket[proc]和一个非空的值列表，即@racket[lst]。它返回列表@racket[lst]中的@emph{first}元素，将结果@racket[proc]最大化。

对@emph{first}的强调是我们的。

例如：

@interaction[#:eval ((make-eval-factory (list 'racket)))
(argmax add1 (list 1 2 3)) 
(argmax sqrt (list .4 .9 .16))
(argmax second '((a 2) (b 3) (c 4) (d 1) (e 4)))
]

下面是对这个函数可能的最简单的合约：

@racketmod[#:file @tt{version 1} 
racket

(define (argmax f lov) ...)

(provide
 (contract-out
  [argmax (-> (-> any/c real?) (and/c pair? list?) any/c)]))
]

本合约捕捉@racket[argmax]的非正式描述的两个必备条件：

@itemlist[

@item{给定的函数必须生成可以依据@racket[<]进行比较的数字。特别是，合约@racket[(-> any/c number?)]不可行，因为@racket[number?]也承认Racket中的复数有效。}

@item{给定列表必须至少包含一项。}

]

当名称组合时，合约解释同级 @racket[argmax]的行为，作为在模块中的机器（ML）函数类型签名（除空表方面外）。

然而，合同可能比类型签名传达更多的信息。看一下@racket[argmax]的第二个合约：

@racketmod[#:file @tt{version 2}
racket

(define (argmax f lov) ...)

(provide
 (contract-out
  [argmax
    (->i ([f (-> any/c real?)] [lov (and/c pair? list?)]) () 
         (r (f lov)
            (lambda (r)
              (define f@r (f r))
              (for/and ([v lov]) (>= f@r (f v))))))]))
]

它是一个@emph{独立（dependent）}的合约，它命名两个参数并使用名称给结果添加一个断言。该断言计算 @racket[(f r)]——这里@racket[r]是@racket[argmax]的结果——并验证了该值大于或等于所有对@racket[lov]项的@racket[f]值。

@racket[argmax]会被返回一个因意外最大化@racket[f]而超过@racket[lov]的所有元素的随机值欺骗是可能的吗？有了合约，就有可能排除这种可能性：

@racketmod[#:file @tt{version 2 rev. a}
racket

(define (argmax f lov) ...)

(provide
 (contract-out
  [argmax
    (->i ([f (-> any/c real?)] [lov (and/c pair? list?)]) () 
         (r (f lov)
            (lambda (r)
              (define f@r (f r))
              (and (memq r lov)
                   (for/and ([v lov]) (>= f@r (f v)))))))]))
]

@racket[memq]函数确保@racket[r] @emph{i等于（ntensionally equal）}@racket[lov]的成员之一。当然，值得反思的是，要弥补这样的值是不可能的。函数是Racket中的不透明值，不使用函数，无法确定某个随机输入值是否产生输出值或触发某些异常。因此我们从这里开始忽略这种可能性。

第2版制定@racket[argmax]文档的整体观点，但它不能传达结果是给定列表的@emph{first}元素，它最大化给定的函数@racket[f]。这是一个传达非正式文件的第二个方面的版本：

@racketmod[#:file @tt{version 3} 
racket

(define (argmax f lov) ...)

(provide
 (contract-out
  [argmax
    (->i ([f (-> any/c real?)] [lov (and/c pair? list?)]) ()
         (r (f lov)
            (lambda (r)
              (define f@r (f r))
              (and (for/and ([v lov]) (>= f@r (f v)))
                   (eq? (first (memf (lambda (v) (= (f v) f@r)) lov)) 
                        r)))))]))
]

那就是，@racket[memf]函数确定@racket[lov]的第一个元素，它的@racket[f]下的值等于@racket[f]下的@racket[r]的值。如果此元素是有意等于@racket[r]，@racket[argmax]的结果就正确。

第二个细化步骤引入了两个问题。首先，两者的条件为@racket[lov]的所有元素重新计算@racket[f]的值。第二，合约现在很难读懂。合约应该有一个简洁的表述，让客户机可以用简单的扫描理解。让我们用具有合理含义的两个辅助函数消除可读性问题：

@(define dominates1
  @multiarg-element['tt]{@list{
   @racket[f@r] is greater or equal to all @racket[(f v)] for @racket[v] in @racket[lov]}})

@(define first?1
  @multiarg-element['tt]{
   @list{@racket[r] is @racket[eq?] to the first element @racket[v] of @racket[lov] 
         for which @racket[(pred? v)]}})

@racketmod[#:file @tt{version 3 rev. a} 
racket

(define (argmax f lov) ...)

(provide
 (contract-out
  [argmax
    (->i ([f (-> any/c real?)] [lov (and/c pair? list?)]) ()
         (r (f lov)
            (lambda (r)
              (define f@r (f r))
              (and (is-first-max? r f@r f lov)
                   (dominates-all f@r f lov)))))]))

@code:comment{where}

@code:comment{@#,dominates1}
(define (dominates-all f@r f lov)
  (for/and ([v lov]) (>= f@r (f v))))

@code:comment{@#,first?1}
(define (is-first-max? r f@r f lov)
  (eq? (first (memf (lambda (v) (= (f v) f@r)) lov)) r))
]

两个判断的名称表示它们的功能，原则上不需要读取它们的定义。

这一步给我们带来了新引进的低效率问题。为了避免为了@racket[lov]上的所有 @racket[v]而重复计算@racket[(f v)]，我们改变合约，以计算这些值和重用它们是必要的：

@(define dominates2
  @multiarg-element['tt]{@list{
   @racket[f@r] is greater or equal to all @racket[f@v] in @racket[flov]}})

@(define first?2
  @multiarg-element['tt]{
   @list{@racket[r] is @racket[(first x)] for the first
         @racket[x] in @racket[lov+flov] s.t. @racket[(= (second x) f@r)]}})

@racketmod[#:file @tt{version 3 rev. b} 
racket

(define (argmax f lov) ...)

(provide
 (contract-out
  [argmax
    (->i ([f (-> any/c real?)] [lov (and/c pair? list?)]) ()
         (r (f lov)
            (lambda (r)
              (define f@r (f r))
              (define flov (map f lov))
              (and (is-first-max? r f@r (map list lov flov))
                   (dominates-all f@r flov)))))]))

@code:comment{where}

@code:comment{@#,dominates2}
(define (dominates-all f@r flov)
  (for/and ([f@v flov]) (>= f@r f@v)))

@code:comment{@#,first?2}
(define (is-first-max? r f@r lov+flov)
  (define fst (first lov+flov))
  (if (= (second fst) f@r)
      (eq? (first fst) r)
      (is-first-max? r f@r (rest lov+flov))))
]

现在对结果的断言为@racket[lov]元素再计算@racket[f]的所有值一次。

版本3也许还太急，当它去调用@racket[f]时。然而无论@racket[lov]包含有多少成员，Racket的@racket[argmax]总是调用@racket[f]，让我们想象我们自己为了说明的目的，实现首先检查列表是否是单独的。如果是这样，第一个元素将是@racket[lov]的唯一元素，在这种情况下就不需要计算@racket[(f r)]。事实上，由于@racket[f]可能发散或增加一些例外输入，argmax应该尽可能避免调用@racket[f]。

下面的合约演示了如何调整高阶依赖合约，以避免过度依赖：

@racketmod[#:file @tt{version 4} 
racket

(define (argmax f lov) 
  (if (empty? (rest lov))
      (first lov)
      ...))

(provide
 (contract-out
  [argmax
    (->i ([f (-> any/c real?)] [lov (and/c pair? list?)]) ()
         (r (f lov)
            (lambda (r)
              (cond
                [(empty? (rest lov)) (eq? (first lov) r)]
                [else
                 (define f@r (f r))
                 (define flov (map f lov))
                 (and (is-first-max? r f@r (map list lov flov))
                      (dominates-all f@r flov))]))))]))

@code:comment{where}

@code:comment{@#,dominates2}
(define (dominates-all f@r lov) ...)

@code:comment{@#,first?2}
(define (is-first-max? r f@r lov+flov) ...)
]

注意，这种考虑不适用于一阶合约的世界。只有高阶（或惰性）语言迫使程序员以如此精确的方式表达合约。

发散或异常提升函数的问题应该提醒读者注意函数的更普遍问题。如果给定的函数@racket[f]有明显的影响——说明日志文件的调用——那么@racket[argmax]的客户机将能够观察每次调用@racket[argmax]的两套日志。要精确，如果值列表包含多个元素，日志将包含每一个@racket[lov]值的两个@racket[f]调用。如果@racket[f]计算太昂贵，则调用次数加倍会造成高成本。

为了避免这种成本和信号过于依赖的合约问题，合同系统可以记录i/o的函数参数和使用这些哈希表的相关规范。这是PLT研究中的一个课题。敬请关注。