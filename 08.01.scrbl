;08.01.scrbl
;08.1 端口的种类
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

@title[#:tag "ports"]{端口的种类}

不同的函数可创建不同类型的端口，这里有一些例子：

@itemize[
         
@item{@bold{文件（Files）：}@racket[open-output-file]函数打开一个可供写入的文件，而@racket[open-input-file]打开一文件以读取其内容。

@(interaction-eval #:eval io-eval (define old-dir (current-directory)))
@(interaction-eval #:eval io-eval (current-directory (find-system-path 'temp-dir)))
@(interaction-eval #:eval io-eval (when (file-exists? "data") (delete-file "data")))

@examples[
#:eval io-eval
(define out (open-output-file "data"))
(display "hello" out)
(close-output-port out)
(define in (open-input-file "data"))
(read-line in)
(close-input-port in)
]

如果一个文件已经存在，@racket[open-output-file]的默认行为是抛出一个异常。提供了选项如@racket[#:exists
'truncate]或@racket[#:exists 'update]来重写或更新文件。

@examples[
#:eval io-eval
(define out (open-output-file "data" #:exists 'truncate))
(display "howdy" out)
(close-output-port out)
]

而不是不得不用关闭（close）调用去匹配（open）调用，绝大多数Racket程序员会使用@racket[call-with-input-file]和@racket[call-with-output-file]，接收一个函数作为参数以执行希望的操作。这个函数仅获取端口参数，操作将自动打开及关闭（端口）。

@examples[
        #:eval io-eval
(call-with-output-file "data"
                        #:exists 'truncate
                        (lambda (out)
                          (display "hello" out)))
(call-with-input-file "data"
                      (lambda (in)
                        (read-line in)))
]

@(interaction-eval #:eval io-eval (when (file-exists? "data") (delete-file "data")))
@(interaction-eval #:eval io-eval (current-directory old-dir))}

@item{@bold{字符串（Strings）：}@racket[open-output-string]创建一个将数据堆入字符串的端口， @racket[get-output-string]将累积而成的字符串解压。@racket[open-input-string]创建一个用于从字符串读取的端口。

@examples[
  #:eval io-eval
  (define p (open-output-string))
  (display "hello" p)
  (get-output-string p)
  (read-line (open-input-string "goodbye\nfarewell"))
  ]}

@item{@bold{TCP连接（TCP Connections）：}@racket[tcp-connect]函数为客户端的TCP通信创建了输入与输出端口。@racket[tcp-listen]函数创建了经由@racket[tcp-accept]接收连接的服务器。

@examples[
  #:eval io-eval
  (eval:alts (define server (tcp-listen 12345)) (void))
  (eval:alts (define-values (c-in c-out) (tcp-connect "localhost" 12345)) (void))
  (eval:alts (define-values (s-in s-out) (tcp-accept server))
             (begin (define-values (s-in c-out) (make-pipe))
                    (define-values (c-in s-out) (make-pipe))))
  (display "hello\n" c-out)
  (close-output-port c-out)
  (read-line s-in)
  (read-line s-in)
  ]}

@item{@bold{进程管道（Process Pipes}）：@racket[subprocess]启动一操作系统级进程并返回与对应子进程stdin、stdout和stderr的端口。（这三种端口是连接到子进程的确定已存在的端口，不需要创建。）

@examples[
  #:eval io-eval
  (eval:alts
   (define-values (p stdout stdin stderr)
     (subprocess #f #f #f "/usr/bin/wc" "-w"))
   (define-values (p stdout stdin stderr)
     (values #f (open-input-string "       3") (open-output-string) (open-input-string ""))))
  (display "a b c\n" stdin)
  (close-output-port stdin)
  (read-line stdout)
  (close-input-port stdout)
  (close-input-port stderr)
  ]}

@item{@bold{内部管道（Internal Pipes）：}@racket[make-pipe]函数返回两个端口代表一个管道的双端。这种类型的管道属于Racket内部，与用于不同进程间通信的系统级管道无关。

@examples[
  #:eval io-eval
  (define-values (in out) (make-pipe))
  (display "garbage" out)
  (close-output-port out)
  (read-line in)
 ]}

]