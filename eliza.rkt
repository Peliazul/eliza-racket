#lang racket

;; Adapted from...
;; https://github.com/apg/chatter

#|
Fixes
  (format (current-output-port) "bye!\n")
becomes
  (display (format "bye!\n))

' becomes \' in defs

TODO:
> weather -- something to do with dynsubs?
|#

(require "bot.rkt")

(define-pre-replacement dont don\'t)
(define-pre-replacement cant can\'t)
(define-pre-replacement wont won\'t)
(define-pre-replacement recollect remember)
(define-pre-replacement dreamt dreamed)
(define-pre-replacement drneams dream)
(define-pre-replacement maybe perhaps)
(define-pre-replacement how what)
(define-pre-replacement when what)
(define-pre-replacement certainly yes)
(define-pre-replacement machine computer)
(define-pre-replacement computers computer)
(define-pre-replacement were was)
(define-pre-replacement you\'re you are)
(define-pre-replacement i\'m i am)
(define-pre-replacement same alike)

(define-post-replacement am are)
(define-post-replacement your my)
(define-post-replacement me you)
(define-post-replacement myself yourself)
(define-post-replacement yourself myself)
(define-post-replacement i you)
(define-post-replacement you I)
(define-post-replacement my your)
(define-post-replacement i\'m you are)

;; TODO - do synonyms actually work?

(define-synonyms (hello)
  (hello hi hola howdy hiya))

(define-synonyms (belief)
  (feel think believe wish))

(define-synonyms (family)
  (family mother mom father dad sister brother wife children child 
          uncle aunt grandma grandpa cousin mum))

(define-synonyms (desire) 
  (want need))

(define-synonyms (sad) 
  (unhappy depressed sick))

(define-synonyms (happy) 
  (elated glad better))

(define-synonyms (cannot) 
  (can\'t))

(define-synonyms (everyone) 
  (nobody noone))

(define-synonyms (be) 
  (am is are was))

(define-keyword (weather)
  ((* what is the weather *)
   (Looks like it\'s (> weather))
   (Do I look like a weatherman ?)
   (What does a forecast mean to a therapist ?)))

(define-keyword (xnone)
  ((*)
   (I\'m not sure I understand you fully)
   (Please go on.)
   (What does that suggest to you ?)
   (Do you feel strongly about discussing such things ?)))

(define-keyword (sorry)
  ((*)
   (Please don\'t apologise.)
   (Apologies are not necessary.)
   (I\'ve told you that apologies are not required.)))

(define-keyword (apologise)
  ((*)
   ((goto sorry))))

(define-keyword (remember 5)
  ((* i remember *)
   (Do you often think of (% 2) ?)
   (Does thinking of (% 2) bring anything else to mind ?)
   (What else do you recollect ?)
   (Why do you recollect (% 2) just now ?)
   (What in the present situation reminds you of (% 2) ?)
   (What is the connection between me and (% 2) ?))
  ((* do you remember *)
   (Did you think I would forget (% 2) ?)
   (Why do you think I should recall (% 2) now ?)
   (What about (% 2) ?)
   ((goto what))
   (You mentioned (% 2) ?)))

(define-keyword (if 3)
  ((* if *)
   (Do you think its likely that (% 2) ?)
   (Do you wish that (% 2) ?)
   (What do you know about (% 2) ?)
   (Really\, if (% 2) ?)))

(define-keyword (dreamed 4)
  ((* i dreamed *)
   (Really\, (% 2) ?)
   (Have you ever fantasized (% 2) while you were awake ?)
   (Have you ever dreamed (% 2) before ?)
   (((goto dream)))))

(define-keyword (dream 3)
  ((*)
   (What does that dream suggest to you ?)
   (Do you dream often ?)
   (What persons appear in your dreams ?)
   (Do you believe that dreams have something to do with your problems ?)))

(define-keyword (perhaps)
  ((*)
   (You don\'t seem quite certain.)
   (Why the uncertain tone ?)
   (Can\'t you be more positive ?)
   (You aren\'t sure ?)
   (Don\'t you know ?)))

(define-keyword (name 15)
  ((*)
   (I am not interested in names.)
   (I\'ve told you before\, I don\'t care about names -- please continue.)))

(define-keyword (deutsch)
  ((*)
   ((goto xforeign))
   (I told you before\, I don\'t understand German.)))

(define-keyword (francais)
  ((*)
   ((goto xforeign))
   (I told you before\, I don\'t understand French.)))


(define-keyword (italiano)
  ((*)
   ((goto xforeign))
   (I told you before\, I don\'t understand Italian.)))


(define-keyword (espanol)
  ((*)
   ((goto xforeign))
   (I told you before\, I don\'t understand Spanish.)))


(define-keyword (xforeign)
  ((*)
   (I speak only English.)))


(define-keyword (hello)
  ((*)
   (How do you do.  Please state your problem.)
   (Hi.  What seems to be your problem ?)))


(define-keyword (computer 50)
  ((*)
   (Do computers worry you ?)
   (Why do you mention computers ?)
   (What do you think machines have to do with your problem ?)
   (Don\'t you think computers can help people ?)
   (What about machines worrys you ?)
   (What do you think about machines ?)))


(define-keyword (am)
  ((* am i *)
   (Do you believe you are (% 2) ?)
   (Would you want to be (% 2) ?)
   (Do you wish I would tell you you are (% 2) ?)
   (What would it mean if you were (% 2) ?)
   ((goto what)))
  ((*)
   (Why do you say \'am\' ?)
   (I don\'t understand that.)))


(define-keyword (are)
  ((* are you *)
   (Why are you interested in whether I am (% 2) or not ?)
   (Would you prefer if I weren\'t (% 2) ?)
   (Perhaps I am (% 2) in your fantasies.)
   (Do you sometimes think I am (% 2) ?)
   ((goto what)))
  ((* are *)
   (Did you think they might not be (% 2) ?)
   (Would you like it if they were not (% 2) ?)
   (What if they were not (% 2) ?)
   (Possibly they are (% 2))))


(define-keyword (your)
  ((* your *)
   (Why are you concerned over my (% 2) ?)
   (What about your own (% 2) ?)
   (Are you worried about someone else\'s (% 2) ?)
   (Really\, my (% 2) ?)))


(define-keyword (was 2)
  ((* was i *)
   (What if you were (% 2) ?)
   (Do you think you were (% 2) ?)
   (Were you (% 2) ?)
   (What would it mean if you were (% 2) ?)
   (What does (% 2) suggest to you ?)
   ((goto what)))
  ((* i was *)
   (Were you really ?)
   (Why do you tell me you were (% 2) now ?)
   (Perhaps I already know you were (% 2)))
  ((* was you *)
   (Would you like to believe I was (% 2) ?)
   (What suggests that I was (% 2) ?)
   (What do you think ?)
   (Perhaps I was (% 2))
   (What if I had been (% 2) ?)))


(define-keyword (i)
  ((* i (@ desire) *)
   (What would it mean to you if you got (% 3) ?)
   (Why do you want (% 3) ?)
   (Suppose you got (% 3) soon ?)
   (What if you never got (% 3) ?)
   (What would getting (% 3) mean to you ?)
   (What does wanting (% 3) have to do with this discussion ?))
  ((* i am* (@ sad) *)
   (I am sorry to hear that you are (% 3))
   (Do you think that coming here will help you not to be (% 3) ?)
   (I\'m sure it\'s not pleasant to be (% 3))
   (Can you explain what made you (% 3) ?))
  ((* i am* (@ happy) *)
   (How have I helped you to be (% 3) ?)
   (Has your treatment made you (% 3) ?)
   (What makes you (% 3) just now ?)
   (Can you explan why you are suddenly (% 3) ?))
  ((* i was *)
   ((goto was)))
  ((* i (@ belief) * i *)
   (Do you really think so ?)
   (But you are not sure you (% 3))
   (Do you really doubt you (% 3) ?))
  ((* i* (@ belief) *you *)
   ((goto you)))
  ((* i am *)
   (Is it because you are (% 2) that you came to me ?)
   (How long have you been (% 2) ?)
   (Do you believe it is normal to be (% 2) ?)
   (Do you enjoy being (% 2) ?))
  ((* i (@ cannot) *)
   (How do you think that you can\'t (% 3) ?)
   (Have you tried ?)
   (Perhaps you could (% 3) now.)
   (Do you really want to be able to (% 3) ?))
  ((* i don\'t *)
   (Don\'t you really (% 2) ?)
   (Why don\'t you (% 2) ?)
   (Do you wish to be able to (% 2) ?)
   (Does that trouble you ?))
  ((* do i feel *)
   (Tell me more about such feelings.)
   (Do you often feel (% 2) ?)
   (Do you enjoy feeling (% 2) ?)
   (Of what does feeling (% 2) remind you ?))
  ((* i * you *)
   (Perhaps in your fantasies we (% 2) each other.)
   (Do you wish to (% 2) me ?)
   (You seem to need to (% 2) me.)
   (Do you (% 2) anyone else ?))
  ((*)
   (You say (% 1) ?)
   (Can you elaborate on that ?)
   (Do you say (% 1) for some special reason ?)
   (That\'s quite interesting.)))


(define-keyword (you)
  ((* you remind me of *)
   ((goto alike)))
  ((* you are *)
   (What makes you think I am (% 2) ?)
   (Does it please you to believe I am (% 2) ?)
   (Do you sometimes wish you were (% 2) ?)
   (Perhaps you would like to be (% 2)))
  ((* you* me *)
   (Why do you think I (% 2) you ?)
   (You like to think I (% 2) you -- don\'t you ?)
   (What makes you think I (% 2) you ?)
   (Really\, I (% 2) you ?)
   (Do you wish to believe I (% 2) you ?)
   (Suppose I did (% 2) you -- what would that mean ?)
   (Does someone else believe I (% 2) you ?))
  ((* you *)
   (We were discussing you -- not me.)
   (Oh\, I (% 2) ?)
   (You\'re not really talking about me -- are you ?)
   (What are your feelings now ?)))


(define-keyword (yes)
  ((*)
   (You seem to be quite positive.)
   (You are sure.)
   (I see.)
   (I understand.)))


(define-keyword (no)
  ((*)
   (Are you saying no just to be negative?)
   (You are being a bit negative.)
   (Why not ?)
   (Why \'no\' ?)))


(define-keyword (my 2)
  (($ * my *)
   (Lets discuss further why your (% 2))
   (Earlier you said your (% 2))
   (But your (% 2))
   (Does that have anything to do with the fact that your (% 2) ?))
  ((* my* (@ family) *)
   (Tell me more about your family.)
   (Who else in your family (% 4) ?)
   (Your (% 3) ?)
   (What else comes to mind when you think of your (% 3) ?))
  ((* my *)
   (Your (% 2) ?)
   (Why do you say your (% 2) ?)
   (Does that suggest anything else which belongs to you ?)
   (Is it important that your (% 2) ?)))


(define-keyword (can)
  ((* can you *)
   (You believe I can (% 2) don\'t you ?)
   ((goto what))
   (You want me to be able to (% 2))
   (Perhaps you would like to be able to (% 2) yourself.))
  ((* can i *)
   (Whether or not you can (% 2) depends on you more than me.)
   (Do you want to be able to (% 2) ?)
   (Perhaps you don\'t want to (% 2))
   ((goto what))))


(define-keyword (what)
  ((*)
   (Why do you ask ?)
   (Does that question interest you ?)
   (What is it you really wanted to know ?)
   (Are such questions much on your mind ?)
   (What answer would please you most ?)
   (What do you think ?)
   (What comes to mind when you ask that ?)
   (Have you asked such questions before ?)
   (Have you asked anyone else ?)))


(define-keyword (because)
  ((*)
   (Is that the real reason ?)
   (Don\'t any other reasons come to mind ?)
   (Does that reason seem to explain anything else ?)
   (What other reasons might there be ?)))


(define-keyword (why)
  ((* why don\'t you *)
   (Do you believe I don\'t (% 2) ?)
   (Perhaps I will (% 2) in good time.)
   (Should you (% 2) yourself ?)
   (You want me to (% 2) ?)
   ((goto what)))
  ((* why can\'t i *)
   (Do you think you should be able to (% 2) ?)
   (Do you want to be able to (% 2) ?)
   (Do you believe this will help you to (% 2) ?)
   (Have you any idea why you can\'t (% 2) ?)
   ((goto what)))
  ((*)
   ((goto what))))


(define-keyword (everyone 2)
  ((* (@ everyone) *)
   (Realy\, (% 2) ?)
   (Surely not (% 2))
   (Can you think of anyone in particular ?)
   (Who\, for example?)
   (Are you thinking of a very special person ?)
   (Who\, may I ask ?)
   (Someone special perhaps ?)
   (You have a particular person in mind\, don\'t you ?)
   (Who do you think you\'re talking about ?)))


(define-keyword (everybody 2)
  ((*)
   ((goto everyone))))


(define-keyword (nobody 2)
  ((*)
   ((goto everyone))))


(define-keyword (noone 2)
  ((*)
   ((goto everyone))))


(define-keyword (always 1)
  ((*)
   (Can you think of a specific example ?)
   (When ?)
   (What incident are you thinking of ?)
   (Really\, always ?)))


(define-keyword (alike 10)
  ((*)
   (In what way ?)
   (What resemblence do you see ?)
   (What does that similarity suggest to you ?)
   (What other connections do you see ?)
   (What do you suppose that resemblence means ?)
   (What is the connection\, do you suppose ?)
   (Could here really be some connection ?)
   (How ?)))


(define-keyword (like 10)
  ((* (@ be) *like *)
   ((goto alike))))


(define (get-input)
  (begin
    (display "you> ")
    (read-line)))

(define (main)
  (define (output foo)
    (begin
      (display (format "Eliza> ~a\n" foo))))
  (display (format
            "Hi, I'm Eliza bot. Type stuff, and I'll respond\n"))
  (let loop ((lin (get-input)))
    (if (eof-object? lin)
        (display (format "bye!\n"))
        (begin
          (output (respond-to lin))
          (loop (get-input))))))


(main)