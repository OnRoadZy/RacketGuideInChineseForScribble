;07.03.06.scrbl
;7.3.6 参数和结果的依赖
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "utils.rkt"
          (for-label framework/framework
                     racket/contract
                     racket/gui))

@title[#:tag "arrow-d"]{参数和结果的依赖}

以下是来自一个虚构的数值模块的摘录：

@racketblock[
(provide
 (contract-out
  [real-sqrt (->i ([argument (>=/c 1)])
                  [result (argument) (<=/c argument)])]))
]

为导出函数@racket[real-sqrt]的合约，使用@racket[->i]函数合约比@racket[->*]更好。“i”代表是一个@italic{印依赖合约（indy dependent contract）}（意味着责任可能被分配到合同本身，因为合同必须被认为是一个独立的组件），意味着作用范围的合约取决于该参数的值。为了 @racket[result]的合约的实现在程序行中出现@racket[argument]意味着结果取决于参数。在特别情况下，@racket[real-sqrt]的参数大于或等于1，那么一个很基本的正确性检查是，结果小于参数。

一般来说，一个从属函数合约看起来更像一般的@racket[->*]合约，但添加的名称可以在合约的其它地方使用。

回到银行帐户示例，假设我们将模块泛化为支持多个帐户，并且我们还包括一个取款操作。改进后的银行帐户模块包括@racket[account]结构类型和以下函数：

@racketblock[
(provide (contract-out
          [balance (-> account? amount/c)]
          [withdraw (-> account? amount/c account?)]
          [deposit (-> account? amount/c account?)]))
]

但是，除了要求客户为取款提供有效金额外，金额应小于或等于指定账户的余额，由此产生的账户将比开始时的钱少。同样，该模块可能承诺存款产生一个帐户，加上账户中的钱。以下实现通过契约强制执行这些约束和保证：

@racketmod[
racket

(code:comment "第1节: 合约定义")
(struct account (balance))
(define amount/c natural-number/c)

(code:comment "第2节: 导出")
(provide
 (contract-out
  [create   (amount/c . -> . account?)]
  [balance  (account? . -> . amount/c)]
  [withdraw (->i ([acc account?]
                  [amt (acc) (and/c amount/c (<=/c (balance acc)))])
                 [result (acc amt)
                         (and/c account? 
                                (lambda (res)
                                  (>= (balance res) 
                                      (- (balance acc) amt))))])]
  [deposit  (->i ([acc account?]
                  [amt amount/c])
                 [result (acc amt)
                         (and/c account? 
                                (lambda (res)
                                  (>= (balance res) 
                                      (+ (balance acc) amt))))])]))

(code:comment "第3节: 函数定义")
(define balance account-balance)

(define (create amt) (account amt))

(define (withdraw a amt)
  (account (- (account-balance a) amt)))

(define (deposit a amt)
  (account (+ (account-balance a) amt)))
]

第2节中的合约提供了典型的@racket[create]和@racket[balance]的类型保证。然而，对于@racket[withdraw]和@racket[deposit]，合约检查并保证对@racket[balance]和@racket[deposit]的更为复杂的约束。第二个参数@racket[withdraw]的合约使用@racket[(balance acc)]检查所提供的取款金额是否足够小，其中@racket[acc]是在@racket[->i]之中给定的函数第一个参数的名称。@racket[withdraw]结果的合约使用@racket[acc]和@racket[amt]保证不超过所要求的金额被取回。@racket[deposit]的合约同样使用结果合约中的@racket[acc]和@racket[amount]来保证提供的至少钱存入账户。

正如上面所描述的，当合约检查失败时，错误消息不是很显著。下面的修订在辅助函数@racket[mk-account-contract]中使用了@racket[flat-named-contract]（扁平命名合约），以提供更好的错误消息。

@racketmod[
racket

(code:comment "第1节：合约定义")
(struct account (balance))
(define amount/c natural-number/c)

(define msg> "account a with balance larger than ~a expected")
(define msg< "account a with balance less than ~a expected")

(define (mk-account-contract acc amt op msg)
  (define balance0 (balance acc))
  (define (ctr a)
    (and (account? a) (op balance0 (balance a))))
  (flat-named-contract (format msg balance0) ctr))

(code:comment "第2节：导出")
(provide
 (contract-out
  [create   (amount/c . -> . account?)]
  [balance  (account? . -> . amount/c)]
  [withdraw (->i ([acc account?]
                  [amt (acc) (and/c amount/c (<=/c (balance acc)))])
                 [result (acc amt) (mk-account-contract acc amt >= msg>)])]
  [deposit  (->i ([acc account?]
                  [amt amount/c])
                 [result (acc amt) 
                         (mk-account-contract acc amt <= msg<)])]))

(code:comment "第3节：函数定义")
(define balance account-balance)

(define (create amt) (account amt))

(define (withdraw a amt)
  (account (- (account-balance a) amt)))

(define (deposit a amt)
  (account (+ (account-balance a) amt)))
]