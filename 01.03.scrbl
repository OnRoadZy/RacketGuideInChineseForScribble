;1.3 创建可执行文件
#lang scribble/doc
@(require scribble/manual scribble/eval scribble/bnf "guide-utils.rkt"
          (only-in scribble/core link-element)
          (for-label racket/enter))

@(define piece-eval (make-base-eval))

@title{创建可执行文件}

如果你的文件（或在DrRacket的定义区域）包含：

@racketmod[
            racket
 
            (define (extract str)
              (substring str 4 7))
            
            (extract "the cat out of the bag")]

那么它是一个在运行时打印“cat” 的完整程序。你可以在DrRacket中运行程序或在racket中使用enter!，但如果程序被保存在‹src-filename›中，你也可以从命令行运行

@commandline{racket @nonterm{src-filename}}

将程序打包为可执行文件，您有几个选项：
@itemize[
         @item{在DrRacket，你可以选择@menuitem["Racket" "Create Executable..."]菜单项。}
         @item{从命令提示符，运行@exec{raco exe @nonterm{src-filename}}，这里nonterm{src-filename}包含程序。（参见《raco exe: Creating Stand-Alone Executables 》部分获取更多信息。）}
         @item{在UNIX或Mac OS中，可以通过在文件的开头插入以下行将程序文件转换为可执行脚本：

@verbatim[#:indent 2]{#! /usr/bin/env racket }

同时，在命令行中用@exec{chmod +x @nonterm{filename}} 改变文件权限去执行。
 
只要@exec{racket}在用户的可执行搜索路径中脚本就会工作。另外，在@tt{#!}后使用完整路径提交给@exec{racket}（在#!和路径之间有空格），在这种情况下用户的可执行搜索路径无关紧要。}]
