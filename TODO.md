Eliza for Racket - To Do
------------------------

* (* you remind me of *) crashes?

* Rework keywords -- e.g. "am" is a bit simple and clashes with "I"

* Phrases when user repeats themselves

* Earlier you mentioned... - 


Later
-----

* Build a bit of a profile about the patient, based on
  spotted words (nouns, verbs etc?)

* Add a server so that people can chat via telnet

* Recognise "it" in successive sentences.

Done
----

* Make "hi" work like "hello"

* "bye" "quit" etc -- `(define END-PHRASES '(bye goodbye adios))`

* Understand and recode `process` -- does it need continuations?
  Yes for now, for ((goto ...)) keywords

* Make the responses random

* ((* i am* (@ sad) *) doesn't work

* In keywords final (*) seems to beat all others

Responses to improve
--------------------

you> my children laugh at me
Eliza> What else comes to mind when you think of your laugh at you ?

((* my (@ family) *) responses
  
you> when i get home from work
Eliza> Do you say what you get home from work for some special reason ?