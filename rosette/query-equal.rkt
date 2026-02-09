#lang rosette

(require "syntax.rkt" "table.rkt")

(provide query-equal?
         val-equal?
         filter-equal?)

;;; Direct structural comparison for relational expressions
;;; These functions compare query AST structures syntactically,
;;; not semantically (which is handled by the 'same' function in util.rkt)

;;; Compare two query structures for syntactic equality
(define (query-equal? q1 q2)
  (cond
    ;; Both are query-select
    [(and (query-select? q1) (query-select? q2))
     (and (vals-equal? (query-select-select-args q1) (query-select-select-args q2))
          (query-equal? (query-select-from-query q1) (query-select-from-query q2))
          (filter-equal? (query-select-where-filter q1) (query-select-where-filter q2)))]
    
    ;; Both are query-select-distinct
    [(and (query-select-distinct? q1) (query-select-distinct? q2))
     (and (vals-equal? (query-select-distinct-select-args q1) (query-select-distinct-select-args q2))
          (query-equal? (query-select-distinct-from-query q1) (query-select-distinct-from-query q2))
          (filter-equal? (query-select-distinct-where-filter q1) (query-select-distinct-where-filter q2)))]
    
    ;; Both are query-join
    [(and (query-join? q1) (query-join? q2))
     (and (query-equal? (query-join-query1 q1) (query-join-query1 q2))
          (query-equal? (query-join-query2 q1) (query-join-query2 q2)))]
    
    ;; Both are query-named
    [(and (query-named? q1) (query-named? q2))
     (equal? (query-named-table-ref q1) (query-named-table-ref q2))]
    
    ;; Both are query-rename
    [(and (query-rename? q1) (query-rename? q2))
     (and (query-equal? (query-rename-query q1) (query-rename-query q2))
          (equal? (query-rename-table-name q1) (query-rename-table-name q2)))]
    
    ;; Both are query-rename-full
    [(and (query-rename-full? q1) (query-rename-full? q2))
     (and (query-equal? (query-rename-full-query q1) (query-rename-full-query q2))
          (equal? (query-rename-full-table-name q1) (query-rename-full-table-name q2))
          (equal? (query-rename-full-column-names q1) (query-rename-full-column-names q2)))]
    
    ;; Both are query-left-outer-join
    [(and (query-left-outer-join? q1) (query-left-outer-join? q2))
     (and (query-equal? (query-left-outer-join-query1 q1) (query-left-outer-join-query1 q2))
          (query-equal? (query-left-outer-join-query2 q1) (query-left-outer-join-query2 q2))
          (filter-equal? (query-left-outer-join-pred q1) (query-left-outer-join-pred q2)))]
    
    ;; Both are query-union-all
    [(and (query-union-all? q1) (query-union-all? q2))
     (and (query-equal? (query-union-all-query1 q1) (query-union-all-query1 q2))
          (query-equal? (query-union-all-query2 q1) (query-union-all-query2 q2)))]
    
    ;; Both are query-aggr-general
    [(and (query-aggr-general? q1) (query-aggr-general? q2))
     (and (query-equal? (query-aggr-general-query q1) (query-aggr-general-query q2))
          (filter-equal? (query-aggr-general-where-filter q1) (query-aggr-general-where-filter q2))
          (vals-equal? (query-aggr-general-gb-fields q1) (query-aggr-general-gb-fields q2))
          (vals-equal? (query-aggr-general-select-args q1) (query-aggr-general-select-args q2))
          (filter-equal? (query-aggr-general-having-filter q1) (query-aggr-general-having-filter q2)))]
    
    ;; Different types or unhandled cases
    [else #f]))

;;; Compare two value structures for syntactic equality
(define (val-equal? v1 v2)
  (cond
    ;; Both are val-const
    [(and (val-const? v1) (val-const? v2))
     (equal? (val-const-val v1) (val-const-val v2))]
    
    ;; Both are val-column-ref
    [(and (val-column-ref? v1) (val-column-ref? v2))
     (equal? (val-column-ref-column-name v1) (val-column-ref-column-name v2))]
    
    ;; Both are val-aggr-subq
    [(and (val-aggr-subq? v1) (val-aggr-subq? v2))
     (and (equal? (val-aggr-subq-agg-func v1) (val-aggr-subq-agg-func v2))
          (query-equal? (val-aggr-subq-query v1) (val-aggr-subq-query v2)))]
    
    ;; Both are val-bexpr
    [(and (val-bexpr? v1) (val-bexpr? v2))
     (and (equal? (val-bexpr-binop v1) (val-bexpr-binop v2))
          (val-equal? (val-bexpr-v1 v1) (val-bexpr-v1 v2))
          (val-equal? (val-bexpr-v2 v1) (val-bexpr-v2 v2)))]
    
    ;; Both are val-uexpr
    [(and (val-uexpr? v1) (val-uexpr? v2))
     (and (equal? (val-uexpr-op v1) (val-uexpr-op v2))
          (val-equal? (val-uexpr-val v1) (val-uexpr-val v2)))]
    
    ;; Different types or unhandled cases
    [else #f]))

;;; Compare lists of values
(define (vals-equal? vals1 vals2)
  (cond
    [(and (empty? vals1) (empty? vals2)) #t]
    [(or (empty? vals1) (empty? vals2)) #f]
    [(not (= (length vals1) (length vals2))) #f]
    [else (andmap val-equal? vals1 vals2)]))

;;; Compare two filter structures for syntactic equality
(define (filter-equal? f1 f2)
  (cond
    ;; Both are filter-binop
    [(and (filter-binop? f1) (filter-binop? f2))
     (and (equal? (filter-binop-op f1) (filter-binop-op f2))
          (val-equal? (filter-binop-val1 f1) (filter-binop-val1 f2))
          (val-equal? (filter-binop-val2 f1) (filter-binop-val2 f2)))]
    
    ;; Both are filter-conj
    [(and (filter-conj? f1) (filter-conj? f2))
     (and (filter-equal? (filter-conj-f1 f1) (filter-conj-f1 f2))
          (filter-equal? (filter-conj-f2 f1) (filter-conj-f2 f2)))]
    
    ;; Both are filter-disj
    [(and (filter-disj? f1) (filter-disj? f2))
     (and (filter-equal? (filter-disj-f1 f1) (filter-disj-f1 f2))
          (filter-equal? (filter-disj-f2 f1) (filter-disj-f2 f2)))]
    
    ;; Both are filter-not
    [(and (filter-not? f1) (filter-not? f2))
     (filter-equal? (filter-not-f1 f1) (filter-not-f1 f2))]
    
    ;; Both are filter-exists
    [(and (filter-exists? f1) (filter-exists? f2))
     (query-equal? (filter-exists-query f1) (filter-exists-query f2))]
    
    ;; Both are filter-true
    [(and (filter-true? f1) (filter-true? f2)) #t]
    
    ;; Both are filter-false
    [(and (filter-false? f1) (filter-false? f2)) #t]
    
    ;; Both are filter-nary-op
    [(and (filter-nary-op? f1) (filter-nary-op? f2))
     (and (equal? (filter-nary-op-f f1) (filter-nary-op-f f2))
          (vals-equal? (filter-nary-op-args f1) (filter-nary-op-args f2)))]
    
    ;; Different types or unhandled cases
    [else #f]))
