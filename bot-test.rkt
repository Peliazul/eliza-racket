#lang racket

(require rackunit "bot.rkt")
(require/expose "bot.rkt" (pre-process-msg process destructure
                                           synonyms-of))

(define-pre-replacement maybe perhaps)

(define-synonyms (everyone) 
  (nobody noone))

(define-keyword (xnone)
  ((*)
   (A sentence for xnone)))

(define-keyword (sorry)
  ((*)
   (Please don\'t apologise.)))

(define-keyword (perhaps)
  ((*)
   (You don\'t seem quite certain.)))

(define-keyword (was 2)
  ((* was i *)
   (What if you were (% 2) ?)))

(define-keyword (you)
  ((* you *)
   (Oh\, I (% 2) ?)))

(define-keyword (everyone 2)
  ((* (@ everyone) *)
   (Surely not (% 2))))

;; -----------------------------------------------------------

#|
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
 "process tests"
 (check-equal? (process '(everyone))
               '(Surely not)))
|#

(test-case
 "synonyms-of tests"
 (check-equal? (synonyms-of 'everyone)
               '('everyone nobody noone)))

(test-case
 "destructure tests"
 (check-equal? (destructure '() '())
               '())
;; (check-equal? (destructure '(*) '(apples and oranges))
;;               '(will fail for now))
;; (check-equal? (destructure '(* you *) '(you like noise))
;;               '(will fail for now))
 (check-equal? (destructure '(* (@ everyone) *) '(nobody loves me))
               '(will fail for now))
 (check-equal? (destructure '(* (@ everyone) *) '(everyone))
               '(will fail for now))
 )

#|
(test-case
 "respond-to tests"
 (check-equal? (respond-to "apple and banana")
               "A sentence for xnone")
 (check-equal? (respond-to "SORRY")
               "Please don't apologise.")
 (check-equal? (respond-to "maybe I'm sick")
               "You don't seem quite certain.")
 (check-equal? (respond-to "perhaps I'm sick")
               "You don't seem quite certain.")
 (check-equal? (respond-to "was i asleep")
               "What if you were asleep ?")
 (check-equal? (respond-to "you like noise")
               "Oh, I like noise ?")
;; (check-equal? (respond-to "everyone")
;;              "Surely not")
 )
|#

;; Tests to do
;; synonyms
;; everyone
