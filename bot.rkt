#lang racket

;; Original version copyright 2011, Andrew Gwozdziewycz web@apgwoz.com
;; Changes copyright 2015, Eric Clack, eric@bn7.net
;; This program is distributed under the terms of the GNU General Public License

;; Uncomment one of these lines...
;;(require unstable/debug)
(define (debug x) void)

#|

Bugs (-- see tests too)

look ahead in destructure doesn't seem to support synonyms
-- but does it need to?

|#



(define *DYNAMIC-SUBSTITUTIONS* (make-hash))
(define *KEYWORD-WEIGHTS* (make-hash))
(define *KEYWORD-PATTERNS* (make-hash))
(define *WORD-SYNONYMS* (make-hash))
(define *POST-REPLACEMENTS* (make-hash)) 
(define *PRE-REPLACEMENTS* (make-hash))


;;;; TODO: turn this into a cycled stream
(define (make-cycled-list lst)
  (lambda ()
    (let* ((first (car lst))
           (new (append (cdr lst) (list first))))
      (set! lst new)
      first)))

;;;; sort keys by their cadr
(define (sort-list-cadr lofv cmpfn)
  (sort lofv (lambda (x y) (cmpfn (cadr x) (cadr y)))))


;;;; lookup all the keys in table, ignoring them if they aren't found.
(define (hash-ref-all table keys)
  (let loop ((keys keys)
             (accum '()))
    (if (null? keys)
        accum
        (let ((f (hash-ref table (car keys) #f)))
          (loop (cdr keys)
                (if f
                    (cons (list (car keys) f) accum)
                    accum))))))

(define (flatten list)
  (cond 
   ((null? list) '())
   ((not (pair? list)) list)
   ((list? (car list)) (append (flatten (car list)) (flatten (cdr list))))
   (else
    (cons (car list) (flatten (cdr list))))))

;;;; given words, return a list of `keywords' in descending order 
;;;; by weight to extract patterns from
(define (relevant-keywords weights words)
  (map car (sort-list-cadr (hash-ref-all weights words) >)))

(define (synonyms-of base)
  (hash-ref *WORD-SYNONYMS* base '()))

(define (post-replace x)
  (hash-ref *POST-REPLACEMENTS* x x))

(define (pre-replace x)
  (hash-ref *PRE-REPLACEMENTS* x x))

(define (thing->string x)
  (cond
   ((string? x) x)
   ((number? x) (number->string x))
   ((symbol? x) (symbol->string x))
   (else (format #f "~a" x))))

(define (string->thing x)
  (with-input-from-string x read))


;;;; reassembles the reassembly by evaluating the things to do
;;;; TODO: reassemble an assembly so that we can generate goto's dynamically
;;;; reassemble needs an escape procedure such that when a goto occurs
;;;; it can restart
(define (reassemble expr dynsubs vars goto-handler)
  (flatten
   (map 
    (lambda (x)
      (if (pair? x)
          (let ((operator (car x))
                (args (cdr x)))
            (cond
             ;; if goto found, invoke the goto-handler with a new list
             ;; of keywords to search (in this case only 1)
             ((eq? operator 'goto) (goto-handler (list (car args))))
             ((eq? operator '>) 
              (let ((dyn-subst (hash-ref dynsubs
                                         (car args))))
                (if (not dyn-subst) 
                    (error (format #f 
                                   "dynamic substitution for ~a not found"
                                   (car args)))
                    (apply dyn-subst (cdr args))))) 
             ((eq? operator '%) (map post-replace (list-ref vars (- (car args) 1))))))
          x))
    expr)))


(define (destructure pat dat)
  ;; Try to match up dat with specified pattern, returting #f if no match
  ;; or returning unmatched parts of dat in the case of wildcards (true)
  ;;
  ;; pat is the pattern to match, like '(* you *)
  ;; dat is the data input by the user, like '(you like noise)
  ;;
  ;; See bot-tests.rkt for examples of what this proc produces

  (define (wildcard? pat)
    (and (not (null? pat))
         (eq? (car pat) '*)))
  (define (synonym? pat)
    (and (not (null? pat))
         (pair? pat)
         (eq? (car pat) '@)))
  (define (a-synonym-of? word pat)
    (memq word (synonyms-of (cadr pat))))
  
  (define (match pat dat collected frame)
    ;; collected is ???
    ;; frame is ???
    (let ((wild? (wildcard? pat)))
      (debug (list pat dat collected frame))
      (cond
       [(and (null? pat) (null? dat))
        ;; finished, so return frame
        (reverse frame)]
       [(null? pat) #f] ;; we've got dat left unmatched
       [(null? dat) ;; no dat left, but maybe pat is at a 
                    ;; wildcard, in which case we're fine
        (and wild?
             (reverse (cons (reverse collected) frame)))]
       [wild?
        ;; 1 symbol lookahead - check if the next thing in
        ;; pat (after the *) matches the head of dat
        (let ((next-pat (if (pair? (cdr pat))
                            (cadr pat)
                            '())))
          (debug (list pat next-pat))
          (cond
           [(null? next-pat)
            ;; there's nothing more in pat, just return dat
            (reverse (cons dat frame))]
           [(eq? next-pat (car dat))
            ;; we have a match, so skip ahead two symbols in pat
            ;; (the * and the next-pat) and the matching symbol in dat
            (debug 1)
            (match (cddr pat) (cdr dat) '()
              (cons (reverse collected) frame))]
           ;; TODO we must check for synonyms?
           [(and (synonym? next-pat) (a-synonym-of? (car dat) next-pat))
            (match (cddr pat) (cdr dat) '()
              (cons (reverse collected) frame))]
           [else
            ;; we don't have a match on next-symbol so keep
            ;; the * in pat (so that it can match more of dat)
            ;; and skip to the next symbol in dat.
            (debug 2)
            (match pat (cdr dat) (cons (car dat) collected) frame)]
           ))]
       [(or (eq? (car pat) (car dat))
            (and (synonym? (car pat)) (a-synonym-of? (car dat) (car pat))))
        ;; A match so move on to next pat and dat
        (match (cdr pat) (cdr dat) '() frame)]
       [else
        ;; No match, give up and return false
        ;;(debug (car pat))
        ;;(debug (synonym? (car pat)))
        #f])))
  (match pat dat '() '()))


(define (pre-process-msg m)
  (flatten 
   (map (compose pre-replace string->symbol)
        (string-split (string-downcase m)))))


(define (post-process-msg w)
  (string-join 
   (map thing->string (flatten w))))


;;;; process list of words by finding the most relevant keywords and 
;;; attempting to match them against the patterns for keyword in order
;;; if there's a successful match, reassemble the next reassembly
;;; and return it
;;;
;;; Complications: goto, patterns that have no match, goto sentinel xnone
;;; Solution: continuations!
(define (process w)
  (let ((kws (append (or (relevant-keywords *KEYWORD-WEIGHTS* w) 
                         '()) 
                     '(xnone))))
    (define goto-handler #f)
    (let kwloop ((kws (call/cc 
                       (lambda (gfn)
                         (set! goto-handler gfn)
                         kws))))
      (if (null? kws)
          '(i have no idea what you want)
          (let ploop ((ps (hash-ref *KEYWORD-PATTERNS* (car kws))))
            (if (null? ps)
                (kwloop (cdr kws)) ;; next kw
                (let* ((pat (caar ps)) ;; caar is first of first
                       (save? #f) 
                       (ms (destructure pat w)))
                  (if ms
                      (reassemble ((cadar ps)) 
                                  *DYNAMIC-SUBSTITUTIONS*
                                  ms
                                  goto-handler)
                      (ploop (cdr ps))))))))))


;;;; find the best match against words given the relevant keywords
(define respond-to
  (compose post-process-msg (compose process pre-process-msg)))


(define (add-patterns! keyword patterns)
  (let ((existing (hash-ref *KEYWORD-PATTERNS* keyword '())))
    (hash-set! *KEYWORD-PATTERNS* 
               keyword
               (append existing 
                       (map 
                        (lambda (pattern)
                          (let ((pat (car pattern))
                                (assems (cdr pattern)))
                            (list pat (make-cycled-list assems))))
                        (reverse patterns))))))


(define (add-synonyms! word syns)
  (let ((existing (hash-ref *WORD-SYNONYMS* word '())))
    (hash-set! *WORD-SYNONYMS* word (cons word syns))))


(define (add-replacement! type from to)
  (hash-set! (if (eq? type 'pre) *PRE-REPLACEMENTS* *POST-REPLACEMENTS*)
             from to))


(define-syntax define-keyword
  (syntax-rules ()
    ((_ (keyword) (pattern ...) ...)
     (define-keyword (keyword 1) (pattern ...) ...))
    ((_ (keyword weight) (pattern ...) ...)
     (begin
       (hash-set! *KEYWORD-WEIGHTS* 'keyword weight)
       (add-patterns! 'keyword '((pattern ...) ...))))))


(define-syntax define-synonyms
  (syntax-rules ()
    ((_ (word) (syn ...))
     (add-synonyms! 'word '(syn ...)))))


(define-syntax define-pre-replacement
  (syntax-rules ()
    ((_ from to ...)
     (add-replacement! 'pre 'from '(to ...)))))


(define-syntax define-post-replacement
  (syntax-rules ()
    ((_ from to ...)
     (add-replacement! 'post 'from '(to ...)))))
                

(define-syntax define-dynamic-subst
  (lambda (stx) 
    (define (syntax->symbol s)
      ;; we want a different name here, dynamic-subst-s
      (datum->syntax s 
                     (string->symbol
                      (string-append
                       "dynamic-subst-"
                       (symbol->string (syntax->datum s))))))
    (syntax-case stx ()
      ((_ (name arg ...) body ...)
       (with-syntax ((fname (syntax->symbol #'name)))
                    #'(begin
                        (define fname (lambda (arg ...) body ...))
                        (hash-set! *DYNAMIC-SUBSTITUTIONS* 'name fname)))))))


(provide respond-to
         add-patterns!
         add-synonyms!
         add-replacement!
         define-keyword
         define-synonyms
         define-pre-replacement
         define-post-replacement
         define-dynamic-subst)
