;07.08.scrbl
;7.8 建立新合约
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "utils.rkt"
          (for-label racket/contract
                     racket/gui))

@(define ex-eval (make-base-eval))
@(ex-eval '(require racket/contract))

@title{建立新合约}

合约在内部表现为函数，它接受合约的信息（归咎于谁，源程序位置,《@|etc|》），并以合约的名义产生（Dana Scott精神）的推断。

一般意义上，推断是接受任意值的函数，并返回满足相应合约的值。例如，只接受整数的推断对应于合约@racket[(flat-contract
integer?)]可以这样写：

@racketblock[
(define int-proj
  (λ (x)
    (if (integer? x)
        x
        (signal-contract-violation))))
]

作为第二个例子，在整数上接受一元函数的推断如下所示：

@racketblock[
(define int->int-proj
  (λ (f)
    (if (and (procedure? f)
             (procedure-arity-includes? f 1))
        (λ (x) (int-proj (f (int-proj x))))
        (signal-contract-violation))))
]

虽然这些推断具有恰当的错误行为，但它们还不太适合作为合约使用，因为它们不适合容纳归咎问题，也不提供良好的错误消息。为了适应这些，合约不只使用简单的推断，而是使用接受一个@tech[#:doc '(lib "scribblings/reference/reference.scrbl")]{归咎对象（blame object）}的函数，将被归咎的双方的名字封装起来，并记录已建立的合约源代码的位置和该合约的名称。然后，它们可以依次传递这些信息给@racket[raise-blame-error]来发出一个良好的错误信息。

下面是这两个推断中的第一个，被改写为在合约系统中使用：

@racketblock[
(define (int-proj blame)
  (λ (x)
    (if (integer? x)
        x
        (raise-blame-error
         blame
         x
         '(expected: "<integer>" given: "~e")
         x))))
]

新的论点指明了谁应该为正面和反面的合约违约负责。

在这个系统中，合约总是建立在双方之间。一方称为服务器，根据合约提供一些值；另一方称为客户机，也根据合约接受值。服务器称为正面位置，客户机称为反面位置。因此，对于整数合约，唯一可能出错的是所提供的值不是整数。因此，永远只有正面的一方（服务器）才能获得归咎。@racket[raise-blame-error]函数总是归咎于正面的一方。

将之与我们的函数合约的推断进行比较：

@racketblock[
(define (int->int-proj blame)
  (define dom (int-proj (blame-swap blame)))
  (define rng (int-proj blame))
  (λ (f)
    (if (and (procedure? f)
             (procedure-arity-includes? f 1))
        (λ (x) (rng (f (dom x))))
        (raise-blame-error
         blame
         f
         '(expected "a procedure of one argument" given: "~e")
         f))))
]

在这种情况下，唯一明确的归咎于涉及到一个非程序提供给合约或程序不接受一个参数的情况。与整数推断一样，这里的归咎也在于这个值的产生，这就是为什么@racket[raise-blame-error]传递@racket[blame]没有改变。

对于定义域和值域的检查是委托给@racket[int-proj]函数，它提供其参数在前面两行@racket[int->int-proj]函数。这里的诀窍是，即使@racket[int->int-proj]函数总是归咎于它所认为的正面，我们可以通过对给定的@tech[#:doc '(lib "scribblings/reference/reference.scrbl")]{归咎对象（blame object）}调用@racket[blame-swap]互换归咎的一方，取代正面一方与反面一方，反之亦然。

然而，这种技术并不仅仅是一个廉价的技巧来让这个例子发挥作用。正方和反方的反转是函数运作行为的自然结果。也就是说，想象在两个模块之间的程序中的值流。首先，一个模块（服务器）定义了一个函数，然后该模块由另一个模块（客户机）所依赖。到目前为止，函数本身必须从原来的，提供模块给依赖的模块。现在，假设依赖模块调用函数，为它提供一个参数。此时，值流反转。参数正在从依赖模块返回到提供模块！客户机正在将参数提供给服务器，服务器将作为客户机接收该值。最后，当函数产生一个结果时，结果会从服务器流向客户机。因此，定义域上的合约颠倒了正方和反方的责任方，就像值流逆转一样。

我们可以利用这个领悟来概括函数合约并构建一个函数，它接受任意两个合约，并为它们之间的函数返回一个合约。

这一推断也更进一步在检测到违反合约的情况下，使用@racket[blame-add-context]来改进错误消息。

@racketblock[
(define (make-simple-function-contract dom-proj range-proj)
  (λ (blame)
    (define dom (dom-proj (blame-add-context blame
                                             "the argument of"
                                             #:swap? #t)))
    (define rng (range-proj (blame-add-context blame
                                               "the range of")))
    (λ (f)
      (if (and (procedure? f)
               (procedure-arity-includes? f 1))
          (λ (x) (rng (f (dom x))))
          (raise-blame-error
           blame
           f
           '(expected "a procedure of one argument" given: "~e")
           f)))))
]

虽然这些推断得到了合约库的支持，并且可以用来构建新的合约，但是合约库也支持不同的API来进行更有效的推断。具体来说，一个@tech[#:doc '(lib "scribblings/reference/reference.scrbl")]{后负推断（late neg projection）}接受一个归咎对象不带反面归咎的信息，然后按照这个顺序返回一个函数，它既接受合约约定的值也接受反方的名称。然后返回的函数依次根据合约返回值。重写@racket[int->int-proj]以使用这个API，看起来像这样：

@interaction/no-prompt[#:eval ex-eval
(define (int->int-proj blame)
  (define dom-blame (blame-add-context blame
                                       "the argument of"
                                       #:swap? #t))
  (define rng-blame (blame-add-context blame "the range of"))
  (define (check-int v to-blame neg-party)
    (unless (integer? v)
      (raise-blame-error
       to-blame #:missing-party neg-party
       v
       '(expected "an integer" given: "~e")
       v)))
  (λ (f neg-party)
    (if (and (procedure? f)
             (procedure-arity-includes? f 1))
        (λ (x)
          (check-int x dom-blame neg-party)
          (define ans (f x))
          (check-int ans rng-blame neg-party)
          ans)
        (raise-blame-error
         blame #:missing-party neg-party
         f
         '(expected "a procedure of one argument" given: "~e")
         f))))]

这种类型的合约的优点是，可以在合同范围的服务器端提供@racket[_blame]参数，而且这个结果可以用于每个不同的客户机。在较简单的情况下，必须为每个客户机创建一个新的归咎对象。

最后一个问题仍然是这个合约可以与合约系统的其它部分一起使用。在上面的函数中，通过为@racket[f]创建一个包装函数来实现这个合约，但是这个包装器函数与@racket[equal?]不协作，它也不让运行时系统知道结果函数与输入函数@racket[f]之间的关系。

为了解决这两个问题，我们应该使用@tech[#:doc '(lib "scribblings/reference/reference.scrbl")]{陪护（chaperones）}而不是仅仅使用@racket[λ]创建包装函数。这里是@racket[int->int-proj]函数被重写以使用陪护：

@interaction/no-prompt[#:eval ex-eval
(define (int->int-proj blame)
  (define dom-blame (blame-add-context blame
                                       "the argument of"
                                       #:swap? #t))
  (define rng-blame (blame-add-context blame "the range of"))
  (define (check-int v to-blame neg-party)
    (unless (integer? v)
      (raise-blame-error
       to-blame #:missing-party neg-party
       v
       '(expected "an integer" given: "~e")
       v)))
  (λ (f neg-party)
    (if (and (procedure? f)
             (procedure-arity-includes? f 1))
        (chaperone-procedure
         f
         (λ (x)
           (check-int x dom-blame neg-party)
           (values (λ (ans)
                     (check-int ans rng-blame neg-party)
                     ans)
                   x)))
        (raise-blame-error
         blame #:missing-party neg-party
         f
         '(expected "a procedure of one argument" given: "~e")
         f))))]

推断就像如上所述的一个情况，但适合于其它你可能制造的新类型的值，可以与合约库的基本类型一起使用。具体来说，我们可以用@racket[make-chaperone-contract]来构建它：

@interaction/no-prompt[#:eval ex-eval
 (define int->int-contract
   (make-contract
    #:name 'int->int
    #:late-neg-projection int->int-proj))]

然后将其与一个值相结合，得到一些合约检查。

@def+int[#:eval 
         ex-eval
         (define/contract (f x)
           int->int-contract
           "not an int")
         (f #f)
         (f 1)]

@;----------------------------------------------------------
@section{合约结构属性}

对于一次性合约来说，@racket[make-chaperone-contract]函数是可以的，但通常你想做许多不同的合约，只在某些部分有所不同。做到这一点的最好方法是使用一个@racket[struct]（结构），带@racket[prop:contract]、@racket[prop:chaperone-contract]或@racket[prop:flat-contract]。

例如，假设我们想做一个@racket[->]合约的简单表，它接受值域的一个合约和定义域的一个合约。我们应该定义一个具有两个字段的结构，并使用@racket[build-chaperone-contract-property]构建我们需要的监护合约属性。

@interaction/no-prompt[#:eval ex-eval
                              (struct simple-arrow (dom rng)
                                #:property prop:chaperone-contract
                                (build-chaperone-contract-property
                                 #:name
                                 (λ (arr) (simple-arrow-name arr))
                                 #:late-neg-projection
                                 (λ (arr) (simple-arrow-late-neg-proj arr))))]

要像@racket[integer?]和@racket[#f]那样对值自动强制进入合约，我们需要调用@racket[coerce-chaperone-contract]（注意这个拒绝模拟合约并对扁平合约不予坚持；做的既可以是这些事情、调用@racket[coerce-contract]，也可以是代替@racket[coerce-flat-contract]。

@interaction/no-prompt[#:eval ex-eval
                              (define (simple-arrow-contract dom rng)
                                (simple-arrow (coerce-contract 'simple-arrow-contract dom)
                                              (coerce-contract 'simple-arrow-contract rng)))]

定义@racket[_simple-arrow-name]是直截了当的；它需要返回一个S表达式来表达合约：

@interaction/no-prompt[#:eval ex-eval
                              (define (simple-arrow-name arr)
                                `(-> ,(contract-name (simple-arrow-dom arr))
                                     ,(contract-name (simple-arrow-rng arr))))]

我们可以用我们前面定义的推断的一般化形式定义一个推断，这个时候使用@tech[#:doc '(lib "scribblings/reference/reference.scrbl")]{监护（chaperones）}：

@interaction/no-prompt[#:eval
                       ex-eval
                       (define (simple-arrow-late-neg-proj arr)
                         (define dom-ctc (get/build-late-neg-projection (simple-arrow-dom arr)))
                         (define rng-ctc (get/build-late-neg-projection (simple-arrow-rng arr)))
                         (λ (blame)
                           (define dom+blame (dom-ctc (blame-add-context blame
                                                                         "the argument of"
                                                                         #:swap? #t)))
                           (define rng+blame (rng-ctc (blame-add-context blame "the range of")))
                           (λ (f neg-party)
                             (if (and (procedure? f)
                                      (procedure-arity-includes? f 1))
                                 (chaperone-procedure
                                  f
                                  (λ (arg) 
                                    (values 
                                     (λ (result) (rng+blame result neg-party))
                                     (dom+blame arg neg-party))))
                                 (raise-blame-error
                                  blame #:missing-party neg-party
                                  f
                                  '(expected "a procedure of one argument" given: "~e")
                                  f)))))]

@def+int[#:eval 
         ex-eval
         (define/contract (f x)
           (simple-arrow-contract integer? boolean?)
           "not a boolean")
         (f #f)
         (f 1)]

@section{所有的警告和报警}

合约中有一些可选部分，@racket[simple-arrow-contract]没有添加。在这一节中，我们将通过所有这些步骤来演示如何实现这些示例。

第一个是一阶检查。这是用@racket[or/c]来确定当它看到一个值时使用哪个高阶参数合约。下面是我们简单箭头合约的功能。

@interaction/no-prompt[#:eval ex-eval
                              (define (simple-arrow-first-order ctc)
                                (λ (v) (and (procedure? v) 
                                            (procedure-arity-includes? v 1))))]

它接受一个值并返回@racket[#f]，如果这个值确实不满足合同，并且如返回@racket[#t]，只要我们能够辨别这个值满足合约，就正是这个值的一阶属性检查。

下一个是随机的生成。合约库中的随机生成分为两部分：随机运用满足合约值的能力和与应用与给定合约相匹配的值的能力，希望发现其中的错误（并试图使它们生成在生成期间在其他地方使用的有趣值）。


为了运用合约，我们需要实现一个赋予@racket[arrow-contract]结构和一些辅助函数。它应该返回两个值：一个函数，它接受合约值并运用它们；外加一个值列表，这个运用过程总会产生。对于我们简单的合约，我们知道我们总能产生值域的值，只要我们可以生成定义域的值（因为我们可以调用函数）。因此，这里有一个函数，它与@racket[build-chaperone-contract-property]合约的@racket[_exercise]参数相匹配：

@interaction/no-prompt[#:eval
                       ex-eval
                       (define (simple-arrow-contract-exercise arr)
                         (define env (contract-random-generate-get-current-environment))
                         (λ (fuel)
                           (define dom-generate 
                             (contract-random-generate/choose (simple-arrow-dom arr) fuel))
                           (cond
                             [dom-generate
                              (values 
                               (λ (f) (contract-random-generate-stash
                                       env
                                       (simple-arrow-rng arr)
                                       (f (dom-generate))))
                               (list (simple-arrow-rng arr)))]
                             [else
                              (values void '())])))]

如果定义域合约可以产生，那么我们知道我们可以通过运用来做一些好的事。在这种情况下，我们返回一个过程，它用我们从定义域生成的东西调用@racket[_f]（这个函数与合约匹配），而且我们也将结果值保存在环境中。我们也返回@racket[(simple-arrow-rng arr)]表明运用总是会产生合约的东西。

如果不能，那么我们只简单地返回一个函数，它不运用(@racket[void])和空列表（表示我们不会生成任何值）。

然后，为了生成与合约相匹配的值，我们定义了一个函数，当给定合约和辅助函数时，它构成一个随机函数。为了帮助它成为一个更有效的测试函数，我们可以运用它接受的任何参数，并也将它们保存到生成环境中，但前提是我们可以生成值域合约的值。

@interaction/no-prompt[#:eval
                       ex-eval
                       (define (simple-arrow-contract-generate arr)
                         (λ (fuel)
                           (define env (contract-random-generate-get-current-environment))
                           (define rng-generate 
                             (contract-random-generate/choose (simple-arrow-rng arr) fuel))
                           (cond
                             [rng-generate
                              (λ ()
                                (λ (arg)
                                  (contract-random-generate-stash env (simple-arrow-dom arr) arg)
                                  (rng-generate)))]
                             [else
                              #f])))]

当随机生成将环境中的某个东西拉出时，它需要能够判断是否一个被传递给@racket[contract-random-generate-stash]的值是试图生成的合约的候选对象。当然，合约传递给@racket[contract-random-generate-stash]的是一个精确的匹配，然后它就可以使用它。但是，如果合约更强大的话它也可以使用这个价值（在它接受更少的值的意义上）。

为了提供这个功能，我们实现了这个函数：

@interaction/no-prompt[#:eval ex-eval
                              (define (simple-arrow-first-stronger? this that)
                                (and (simple-arrow? that)
                                     (contract-stronger? (simple-arrow-dom that)
                                                         (simple-arrow-dom this))
                                     (contract-stronger? (simple-arrow-rng this)
                                                         (simple-arrow-rng that))))]

这个函数接受@racket[_this]和@racket[_that]，两个合约。它保证@racket[_this]将是我们简单的箭头合约之一，因为我们将此函数与简单的箭头实现一起提供。但@racket[_that]参数可能是任何合约。如果同样比较定义域和值域，这个函数通过检查弄明白@racket[_that]是否也是一个简单的箭头合约。当然，还有其它的合约，我们也可以检查（例如，使用@racket[->]或@racket[->*]建立的合约），但我们并不需要。更强的函数是如果不知道答案，允许返回@racket[#f]；但如果它返回@racket[#t]，那么这个合约必须真正地强健。

既然我们已经完成了所有的部分，我们需要传递它们给@racket[build-chaperone-contract-property]，这样合约系统就开始使用它们了：

@interaction/no-prompt[#:eval ex-eval
                              (struct simple-arrow (dom rng)
                                #:property prop:custom-write contract-custom-write-property-proc
                                #:property prop:chaperone-contract
                                (build-chaperone-contract-property
                                 #:name
                                 (λ (arr) (simple-arrow-name arr))
                                 #:late-neg-projection
                                 (λ (arr) (simple-arrow-late-neg-proj arr))
                                 #:first-order simple-arrow-first-order
                                 #:stronger simple-arrow-first-stronger?
                                 #:generate simple-arrow-contract-generate
                                 #:exercise simple-arrow-contract-exercise))
                              
                              (define (simple-arrow-contract dom rng)
                                (simple-arrow (coerce-contract 'simple-arrow-contract dom)
                                              (coerce-contract 'simple-arrow-contract rng)))]

我们还添加了一个@racket[prop:custom-write]属性，使合约正确打印，例如：

@interaction[#:eval ex-eval (simple-arrow-contract integer? integer?)]

（我们使用@racket[prop:custom-write]，因为合约库不能依赖于

@racketmod[racket/generic]

但仍然希望提供一些帮助，以便于使用正确的打印机。）

既然那些已经完成，我们就可以使用新功能。这里是一个随机函数，它由合约库生成，使用我们的@racket[simple-arrow-contract-generate]函数：

@def+int[#:eval 
         ex-eval
         (define a-random-function
           (contract-random-generate 
            (simple-arrow-contract integer? integer?)))
         (a-random-function 0)
         (a-random-function 1)]

下面是体现合约系统现在如何在使用简单箭头合约的函数中自动发现bug：

@def+int[#:eval 
         ex-eval
         (define/contract (misbehaved-f f)
           (-> (simple-arrow-contract integer? boolean?) any)
           (f "not an integer"))
         (contract-exercise misbehaved-f)]

如果我们没有实现@racket[simple-arrow-first-order]，那么@racket[or/c]就不能判断这个程序中使用哪一个@racket[or/c]分支：

@def+int[#:eval
         ex-eval
         (define/contract (maybe-accepts-a-function f)
           (or/c (simple-arrow-contract real? real?)
                 (-> real? real? real?)
                 real?)
           (if (procedure? f)
               (if (procedure-arity-includes f 1)
                   (f 1132)
                   (f 11 2))
               f))
         (maybe-accepts-a-function sqrt)
         (maybe-accepts-a-function 123)]

@(close-eval ex-eval)
