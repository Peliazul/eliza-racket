#lang racket

(require rackunit "bot.rkt")

(define-keyword (xnone)
  ((*)
   (A sentence for xnone)))

(define-keyword (sorry)
  ((*)
   (Please don\'t apologise.)))

(test-case
 "pre-process-msg tests"
 (check-equal? (pre-process-msg "hello")
               '(hello))
 (check-equal? (pre-process-msg "HeLlo")
               '(hello))
 (check-equal? (pre-process-msg "apples AND oranges")
               '(apples and oranges))
 (check-equal? (pre-process-msg "maybe")
               '(perhaps))
 )

(test-case
 "respond-to tests"
 (check-equal? (respond-to "apple and banana")
               "A sentence for xnone"))
 (check-equal? (respond-to "SORRY")
               "Please don\'t apologise."))
