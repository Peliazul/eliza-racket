#lang racket

;; Original version copyright 2011, Andrew Gwozdziewycz web@apgwoz.com
;; Changes copyright 2015, Eric Clack, eric@bn7.net
;; This program is distributed under the terms of the GNU General Public License

;; TODO
;; Something about removing punctuation (? ! ,) etc

(require rackunit "bot.rkt")
(require/expose "bot.rkt" (pre-process-msg process destructure
                                           synonyms-of relevant-keywords
                                           *KEYWORD-WEIGHTS* *KEYWORD-PATTERNS*
                                           remove-punctuation))

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
   (What if you were (% 2) ?))
  ((* i was *)
   (Why do you tell me you were (% 2) now ?)))

(define-keyword (you)
  ((* you *)
   (Oh\, I (% 2) ?)))

(define-keyword (everyone 2)
  ((* (@ everyone) *)
   (Surely not (% 2))))

(define-keyword (chicken)
  ((*)
   (one chicken ?)
   (two chickens ?)
   (three chickens ?)))

;; -----------------------------------------------------------

(test-case
 "relevant-keywords tests"
 (check-equal? (relevant-keywords *KEYWORD-WEIGHTS* '(chicken was here))
               '(was chicken))
 (check-equal? (relevant-keywords *KEYWORD-WEIGHTS* '(i like apples))
               '())
 (check-pred procedure? (cadar (hash-ref *KEYWORD-PATTERNS* 'everyone)))
 )

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
               '(Surely not))

 ;; Test sequence of calls
 (check-equal? (process '(chicken))
               '(one chicken ?))
 (check-equal? (process '(chicken))
               '(two chickens ?))
 (check-equal? (process '(chicken))
               '(three chickens ?)))

(test-case
 "synonyms-of tests"
 (check-equal? (synonyms-of 'everyone)
               '(everyone nobody noone)))

(test-case
 "destructure tests"

 ;; Failing tests that should pass...
 
 ;; Passing tests
 
 (check-equal? (destructure '() '())
               '())
 (check-equal? (destructure '(apple) '(oranges and lemons))
               #f)
 (check-equal? (destructure '(*) '(apples and oranges))
               '((apples and oranges)))
 (check-equal? (destructure '(i am *) '(i love oranges))
               #f)
 (check-equal? (destructure '(i am *) '(i am human))
               '((human)))
 (check-equal? (destructure '(* you *) '(you like noise))
               '(() (like noise)))
 (check-equal? (destructure '(* you *) '(do you like noise))
               '((do) (like noise)))
 (check-equal? (destructure '((@ everyone) *) '(nobody loves me))
               '((loves me)))
 (check-equal? (destructure '((@ everyone) *) '(everyone))
               '(()))
 (check-equal? (destructure '(* (@ everyone) *) '(what about everyone but me))
               '((what about) (but me)))
 (check-equal? (destructure '(* i was *) '(fred liked fruit))
               #f)
)

(test-case
 "respond-to tests"

 ;; Failing tests that should run...

 ;; Passing tests...
 
 (check-equal? (respond-to "no he was")
               "A sentence for xnone")
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
 (check-equal? (respond-to "everyone")
               "Surely not")
 )

(test-case
 "remove-punctuation tests"
 (check-equal? (remove-punctuation "hello? how are you?")
               "hello how are you")
 )
 
;; Tests to do
;; synonyms
;; everyone
