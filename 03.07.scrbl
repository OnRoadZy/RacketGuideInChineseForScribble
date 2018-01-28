;03.07.scrbl
;3.7 关键字（Keyword）
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title{关键字（Keyword）}

一个@deftech{关键字（keyword）}值类似于一个符号（见《符号（Symbols）》（@secref["symbols"]）），但它的打印形式是用前缀@litchar{#:}。

@examples[
(string->keyword "apple")
'#:apple
(eq? '#:apple (string->keyword "apple"))
]

更确切地说，关键字类似于标识符；以同样的方式，可以引用标识符来生成符号，可以引用关键字来生成值。在这两种情况下都使用同一术语“关键字”，但有时我们使用@defterm{关键字值（keyword value）}更具体地引用引号关键字表达式或使用@racket[string->keyword]过程的结果。一个不带引号的关键字不是表达式，只是作为一个不带引号的标识符不产生符号：

@examples[
not-a-symbol-expression
#:not-a-keyword-expression
]

尽管它们有相似之处，但关键字的使用方式不同于标识符或符号。关键字是为了使用（不带引号）作为参数列表和在特定的句法形式的特殊标记。运行时的标记和枚举，而不是关键字用符号。下面的示例说明了关键字和符号的不同角色。

@examples[
(code:line (define dir (find-system-path 'temp-dir)) (code:comment @#,t{not @racket['#:temp-dir]}))
(with-output-to-file (build-path dir "stuff.txt")
  (lambda () (printf "example\n"))
  (code:comment @#,t{optional @racket[#:mode] argument can be @racket['text] or @racket['binary]})
  #:mode 'text
  (code:comment @#,t{optional @racket[#:exists] argument can be @racket['replace], @racket['truncate], ...})
  #:exists 'replace)
]