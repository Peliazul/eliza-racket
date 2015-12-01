Eliza for Racket
----------------

A text based Eliza chatter bot for Racket.

Example:

    Hi, I'm Eliza bot. Type stuff, and I'll respond
    you> i'm always tired
    Eliza> Can you think of a specific example ?
    you> this morning i really struggled to get up
    Eliza> You say this morning you really struggled to get up ?
    you> yes, it was the same yesterday too
    Eliza> In what way ?
    you> well I couldn't bring myself to get out of bed
    Eliza> Can you elaborate on that ?
    you> i got up after about an hour
    Eliza> Do you say you got up after about an hour for some special reason ?
    you> my dog seems to be able to get up each morning
    Eliza> Your dog seems to be able to get up each morning ?
    you> yes
    Eliza> You seem to be quite positive.
    you> well she doesn't seem to have the problem i have
    Eliza> That's quite interesting.
    you> really?
    Eliza> I'm not sure I understand you fully
    you> how do i crack this problem
    Eliza> How should I know ?
    you> i thought you were a doctor
    Eliza> We were discussing you -- not me.
    you> sorry I asked
    Eliza> You say sorry you asked ?


How to run
----------

Grab the code and load and run `eliza.rkt` in DrRacket.

Tests
-----

There are some unit tests in `bot-tests.rkt` - these are useful to see
how the procs in `bot.rkt` work.

Bugs
----

There are some, probably because of my buggy translation
from the Guile version.

Examples...

    you> weather
    . . hash-ref: no value found for key
      key: 'weather

Let me know any that you find, I might fix them.