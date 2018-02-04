;07.03.01.scrbl
;7.3.1 可选参数
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "utils.rkt"
          (for-label framework/framework
                     racket/contract
                     racket/gui))

@title[#:tag "optional"]{可选参数}

请看一个字符串处理模块的摘录，该灵感来自于《@link["http://schemecookbook.org"]{Scheme cookbook}》：

@racketmod[
racket

(provide
 (contract-out
  (code:comment @#,t{pad the given str left and right with})
  (code:comment @#,t{the (optional) char so that it is centered})
  [string-pad-center (->* (string? natural-number/c)
                          (char?) 
                          string?)]))

(define (string-pad-center str width [pad #\space])
  (define field-width (min width (string-length str)))
  (define rmargin (ceiling (/ (- width field-width) 2)))
  (define lmargin (floor (/ (- width field-width) 2)))
  (string-append (build-string lmargin (λ (x) pad))
                 str
                 (build-string rmargin (λ (x) pad))))
]

模块导出@racket[string-pad-center]，该函数用给定字符串在中心创建一个给定的@racket[width]的字符串。默认的填充字符是@racket[#\space]；如果客户机希望使用一个不同的字符，它可以调用@racket[string-pad-center]，用第三个参数，一个@racket[char]，重写默认的值。

函数定义使用可选参数，这对于这种功能是合适的。这里有趣的一点是@racket[string-pad-center]的合约。

合约组合@racket[->*]，要求几组合约：

@itemize[
@item{第一个是一个对所有必需参数合约的括号组。在这个例子中，我们看到两个：@racket[string?]和@racket[natural-number/c]。}

@item{第二个是对所有可选参数合约的括号组：char?。}

@item{最后一个是一个单一的合约：函数的结果。}
]

请注意，如果默认值不满足合约，则不会获得此接口的合约错误。如果不能信任你自己去正确获得初始值，则需要在边界上传递初始值。