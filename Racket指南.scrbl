;Racket指南.scrbl
;Racket指南
#lang scribble/manual

@;导入参考文献内容及链接：
@(require scribble/eval "guide-utils.rkt")

@title{Racket指南}

@author["Matthew Flatt" "Robert Bruce Findler" "PLT"]
@author["张恒源 译"]

本指南适用于新的Racket程序员或部分新的Racket程序员。本指南假定你是有编程经验的。如果您是新学习编程，那么请阅读《如何设计程序》（@|HtDP|）这部分。如果你想特别快地了解Racket语言，从这里开始：《快速：Racket的图片编程介绍》（@|Quick|）这部分。

第2章简要介绍Racket语言。从第3章开始，本指南深入讨论了大部分的Racket语言工具箱，但把更清晰的细节内容留给Racket语言参考手册和其他参考手册介绍。

@; ----------------------------------------
@table-of-contents[]

@; ----------------------------------------
@include-section["01.scrbl"]
@include-section["02.scrbl"]
@include-section["03.scrbl"]
@include-section["04.scrbl"]
@include-section["05.scrbl"]
@include-section["06.scrbl"]
@include-section["07.scrbl"]
@include-section["08.scrbl"]
@include-section["09.scrbl"]
@include-section["10.scrbl"]
@include-section["11.scrbl"]
@include-section["12.scrbl"]
@include-section["13.scrbl"]
@include-section["14.scrbl"]
@include-section["15.scrbl"]
@include-section["16.scrbl"]

@; --------------------------------------------------

@(bibliography
 
  (bib-entry #:key "Goldberg04"
             #:author "David Goldberg, Robert Bruce Findler, and Matthew Flatt"
             #:title "Super and Inner---Together at Last!"
             #:location "Object-Oriented Programming, Languages, Systems, and Applications"
             #:date "2004"
             #:url "http://www.cs.utah.edu/plt/publications/oopsla04-gff.pdf")

  (bib-entry #:key "Flatt02"
             #:author "Matthew Flatt"
             #:title "Composable and Compilable Macros: You Want it When?"
             #:location "International Conference on Functional Programming"
             #:date "2002")
 
  (bib-entry #:key "Flatt06"
             #:author "Matthew Flatt, Robert Bruce Findler, and Matthias Felleisen"
             #:title "Scheme with Classes, Mixins, and Traits (invited tutorial)"
             #:location "Asian Symposium on Programming Languages and Systems"
             #:url "http://www.cs.utah.edu/plt/publications/aplas06-fff.pdf"
             #:date "2006")
 
 (bib-entry #:key "Mitchell02"
            #:author "Richard Mitchell and Jim McKim"
            #:title "Design by Contract, by Example"
            #:is-book? #t
            #:date "2002")

 (bib-entry #:key "Sitaram05"
            #:author "Dorai Sitaram"
            #:title "pregexp: Portable Regular Expressions for Scheme and Common Lisp"
            #:url "http://www.ccs.neu.edu/home/dorai/pregexp/"
            #:date "2002")

)

@index-section[]