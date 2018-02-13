;08.05.scrbl
;08.5 字节、字符和编码
#lang scribble/doc
@(require scribble/manual
          scribble/struct
          scribble/eval
          racket/system
          "guide-utils.rkt"
          (for-label racket/tcp
                     racket/serialize
                     racket/port))

@(define io-eval (make-base-eval))

@(define (threecolumn a b c)
   (make-table #f
     (list (list (make-flow (list a))
                 (make-flow (list (make-paragraph (list (hspace 1)))))
                 (make-flow (list b))
                 (make-flow (list (make-paragraph (list (hspace 1)))))
                 (make-flow (list c))))))
@(interaction-eval #:eval io-eval (print-hash-table #t))

@title[#:tag "encodings"]{字节、字符和编码}

类似@racket[read-line]、@racket[read]、@racket[display]和@racket[write]这样的函数的工作以@tech{字符（character）}为单位（对应Unicode标量值）。概念上来说，它们经由@racket[read-char]和@racket[write-char]实现。

更初级一点，端口读写@tech{字节（byte）}而非@tech{字符（character）}。@racket[read-byte]与@racket[write-byte]读写原始字节。其它函数，例如@racket[read-bytes-line]，建立在顶层字节操作而非字符操作。

事实上，@racket[read-char]函数和@racket[write-char]函数概念上由@racket[read-byte]和@racket[write-byte]实现。当一个字节的值小于128，它将对应于一个ASCII字符。任何其它的字节会被视为UTF-8序列的一部分，而UTF-8则是字节形式编码Unicode标量值的标准方式之一（具有将ASCII字符原样映射的优点）。此外，一个单次的@racket[read-char]可能会调用多次@racket[read-byte]，一个标准的@racket[write-char]可能生成多个输出字节。

@racket[read-char]和@racket[write-char]操作@emph{总（always）}使用UTF-8编码。如果你有不同编码的文本流，或想以其它编码生成文本流，使用@racket[reencode-input-port]或@racket[reencode-output-port]。@racket[reencode-input-port]将一种你指定编码的输入流转换为UTF-8流；以这种方式，@racket[read-char]能够察觉UTF-8编码，即使原始编码并非如此。应当注意，@racket[read-byte]也看到重编码后的数据，而非原始字节流。