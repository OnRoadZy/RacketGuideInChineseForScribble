;07.03.08.scrbl
;7.3.8 多个结果值
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "utils.rkt"
          (for-label framework/framework
                     racket/contract
                     racket/gui))

@title[#:tag "multiple"]{多个结果值}

函数 @racket[split]接受@racket[char]列表和传递所发生的 @racket[#\newline] 的第一次出现在字符串（如果有）和其余的列表：

@racketblock[
(define (split l)
  (define (split l w)
    (cond
      [(null? l) (values (list->string (reverse w)) '())]
      [(char=? #\newline (car l))
       (values (list->string (reverse w)) (cdr l))]
      [else (split (cdr l) (cons (car l) w))]))
  (split l '()))
]

它是一个典型的多值函数，通过遍历单个列表返回两个值。

这种函数的合约可以使用普通函数箭头@racket[->]，那么当它作为最后结果出现时，@racket[->]特别地处理@racket[values]：

@racketblock[
(provide (contract-out
          [split (-> (listof char?)
                     (values string? (listof char?)))]))
]

这种函数的合约也可以使用@racket[->*]：

@racketblock[
(provide (contract-out
          [split (->* ((listof char?))
                      ()
                      (values string? (listof char?)))]))
]

和以前一样，与@racket[->*]参数的合约被封装在一对额外的圆括号中（并且必须总是这样包装），而空的括号表示没有可选参数。结果的合约是内部的@racket[values]：字符串和字符列表。

现在，假设我们还希望确保第一个结果 @racket[split]是给定列表格式中给定单词的前缀。在这种情况下，我们需要使用@racket[->i]合约的组合： 

@racketblock[
(define (substring-of? s)
  (flat-named-contract
    (format "substring of ~s" s)
    (lambda (s2)
      (and (string? s2)
           (<= (string-length s2) (string-length s))
           (equal? (substring s 0 (string-length s2)) s2)))))

(provide
 (contract-out
  [split (->i ([fl (listof char?)])
              (values [s (fl) (substring-of? (list->string fl))]
                      [c (listof char?)]))]))
]

像@racket[->*]、@racket[->i]组合使用函数中的参数来创建范围的合约。是的，它不只是返回一个合约，而是函数产生值的数量：每个值的一个合约。在这种情况下，第二个合约和以前一样，确保第二个结果是@racket[char]列表。与此相反，第一个合约增强旧的，因此结果是给定单词的前缀。

当然，这个合约检查是很值得的。这里有一个稍微廉价一点的版本：

@racketblock[
(provide
 (contract-out
  [split (->i ([fl (listof char?)])
              (values [s (fl) (string-len/c (length fl))]
                      [c (listof char?)]))]))
]