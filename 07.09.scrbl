;07.09.scrbl
;7.9 陷阱
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          racket/sandbox
          "utils.rkt"
          (for-label racket/base
                     racket/contract))

@title[#:tag "contracts-gotchas"]{陷阱}

@;---------------------------------------------------
@include-section["07.09.01.scrbl"]
@include-section["07.09.02.scrbl"]
@include-section["07.09.03.scrbl"]
@include-section["07.09.04.scrbl"]
@include-section["07.09.05.scrbl"]