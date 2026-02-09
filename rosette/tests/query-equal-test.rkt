#lang rosette

(require "../syntax.rkt" "../query-equal.rkt" "../table.rkt" "../cosette.rkt")

;;; Test suite for query-equal.rkt
;;; Tests direct structural comparison of relational expressions

(displayln "=== Testing Direct Relational Expression Comparison ===")
(displayln "")

;;; Test 1: Simple val-const equality
(displayln "Test 1: val-const equality")
(define v1 (val-const 42))
(define v2 (val-const 42))
(define v3 (val-const 99))
(displayln (format "  val-equal? v1 v2 (same value): ~a (expected: #t)" (val-equal? v1 v2)))
(displayln (format "  val-equal? v1 v3 (different value): ~a (expected: #f)" (val-equal? v1 v3)))
(displayln "")

;;; Test 2: val-column-ref equality
(displayln "Test 2: val-column-ref equality")
(define col1 (val-column-ref "id"))
(define col2 (val-column-ref "id"))
(define col3 (val-column-ref "name"))
(displayln (format "  val-equal? col1 col2 (same column): ~a (expected: #t)" (val-equal? col1 col2)))
(displayln (format "  val-equal? col1 col3 (different column): ~a (expected: #f)" (val-equal? col1 col3)))
(displayln "")

;;; Test 3: val-bexpr equality (binary expressions)
(displayln "Test 3: val-bexpr equality")
(define bexpr1 (val-bexpr + (val-const 1) (val-const 2)))
(define bexpr2 (val-bexpr + (val-const 1) (val-const 2)))
(define bexpr3 (val-bexpr + (val-const 1) (val-const 3)))
(define bexpr4 (val-bexpr * (val-const 1) (val-const 2)))
(displayln (format "  val-equal? bexpr1 bexpr2 (same expr): ~a (expected: #t)" (val-equal? bexpr1 bexpr2)))
(displayln (format "  val-equal? bexpr1 bexpr3 (different operand): ~a (expected: #f)" (val-equal? bexpr1 bexpr3)))
(displayln (format "  val-equal? bexpr1 bexpr4 (different op): ~a (expected: #f)" (val-equal? bexpr1 bexpr4)))
(displayln "")

;;; Test 4: val-uexpr equality (unary expressions)
(displayln "Test 4: val-uexpr equality")
(define uexpr1 (val-uexpr - (val-const 5)))
(define uexpr2 (val-uexpr - (val-const 5)))
(define uexpr3 (val-uexpr - (val-const 10)))
(displayln (format "  val-equal? uexpr1 uexpr2 (same expr): ~a (expected: #t)" (val-equal? uexpr1 uexpr2)))
(displayln (format "  val-equal? uexpr1 uexpr3 (different operand): ~a (expected: #f)" (val-equal? uexpr1 uexpr3)))
(displayln "")

;;; Test 5: filter-binop equality
(displayln "Test 5: filter-binop equality")
(define filt1 (filter-binop = (val-column-ref "x") (val-const 10)))
(define filt2 (filter-binop = (val-column-ref "x") (val-const 10)))
(define filt3 (filter-binop > (val-column-ref "x") (val-const 10)))
(displayln (format "  filter-equal? filt1 filt2 (same filter): ~a (expected: #t)" (filter-equal? filt1 filt2)))
(displayln (format "  filter-equal? filt1 filt3 (different op): ~a (expected: #f)" (filter-equal? filt1 filt3)))
(displayln "")

;;; Test 6: filter-conj equality (AND)
(displayln "Test 6: filter-conj equality")
(define f1 (filter-binop = (val-column-ref "x") (val-const 1)))
(define f2 (filter-binop > (val-column-ref "y") (val-const 0)))
(define conj1 (filter-conj f1 f2))
(define conj2 (filter-conj f1 f2))
(define conj3 (filter-conj f2 f1))
(displayln (format "  filter-equal? conj1 conj2 (same conj): ~a (expected: #t)" (filter-equal? conj1 conj2)))
(displayln (format "  filter-equal? conj1 conj3 (reversed): ~a (expected: #f)" (filter-equal? conj1 conj3)))
(displayln "")

;;; Test 7: filter-true and filter-false
(displayln "Test 7: filter-true and filter-false")
(define ftrue1 (filter-true))
(define ftrue2 (filter-true))
(define ffalse1 (filter-false))
(displayln (format "  filter-equal? ftrue1 ftrue2: ~a (expected: #t)" (filter-equal? ftrue1 ftrue2)))
(displayln (format "  filter-equal? ftrue1 ffalse1: ~a (expected: #f)" (filter-equal? ftrue1 ffalse1)))
(displayln "")

;;; Test 8: query-named equality
(displayln "Test 8: query-named equality")
(define tinfo1 (table-info "users" '("id" "name")))
(define tinfo2 (table-info "users" '("id" "name")))
(define tinfo3 (table-info "posts" '("id" "title")))
(define qnamed1 (query-named tinfo1))
(define qnamed2 (query-named tinfo2))
(define qnamed3 (query-named tinfo3))
(displayln (format "  query-equal? qnamed1 qnamed2 (same table): ~a (expected: #t)" (query-equal? qnamed1 qnamed2)))
(displayln (format "  query-equal? qnamed1 qnamed3 (different table): ~a (expected: #f)" (query-equal? qnamed1 qnamed3)))
(displayln "")

;;; Test 9: query-join equality
(displayln "Test 9: query-join equality")
(define q1 (query-named tinfo1))
(define q2 (query-named tinfo3))
(define join1 (query-join q1 q2))
(define join2 (query-join q1 q2))
(define join3 (query-join q2 q1))
(displayln (format "  query-equal? join1 join2 (same join): ~a (expected: #t)" (query-equal? join1 join2)))
(displayln (format "  query-equal? join1 join3 (reversed): ~a (expected: #f)" (query-equal? join1 join3)))
(displayln "")

;;; Test 10: query-select equality
(displayln "Test 10: query-select equality")
(define select1 (query-select 
                 (list (val-column-ref "id"))
                 (query-named tinfo1)
                 (filter-binop = (val-column-ref "id") (val-const 1))))
(define select2 (query-select 
                 (list (val-column-ref "id"))
                 (query-named tinfo1)
                 (filter-binop = (val-column-ref "id") (val-const 1))))
(define select3 (query-select 
                 (list (val-column-ref "name"))
                 (query-named tinfo1)
                 (filter-binop = (val-column-ref "id") (val-const 1))))
(displayln (format "  query-equal? select1 select2 (same select): ~a (expected: #t)" (query-equal? select1 select2)))
(displayln (format "  query-equal? select1 select3 (different column): ~a (expected: #f)" (query-equal? select1 select3)))
(displayln "")

;;; Test 11: query-union-all equality
(displayln "Test 11: query-union-all equality")
(define union1 (query-union-all q1 q2))
(define union2 (query-union-all q1 q2))
(define union3 (query-union-all q2 q1))
(displayln (format "  query-equal? union1 union2 (same union): ~a (expected: #t)" (query-equal? union1 union2)))
(displayln (format "  query-equal? union1 union3 (reversed): ~a (expected: #f)" (query-equal? union1 union3)))
(displayln "")

;;; Test 12: query-rename equality
(displayln "Test 12: query-rename equality")
(define rename1 (query-rename q1 "t1"))
(define rename2 (query-rename q1 "t1"))
(define rename3 (query-rename q1 "t2"))
(displayln (format "  query-equal? rename1 rename2 (same rename): ~a (expected: #t)" (query-equal? rename1 rename2)))
(displayln (format "  query-equal? rename1 rename3 (different name): ~a (expected: #f)" (query-equal? rename1 rename3)))
(displayln "")

;;; Test 13: Complex nested query
(displayln "Test 13: Complex nested query")
(define complex1 (query-select
                  (list (val-column-ref "id") (val-column-ref "name"))
                  (query-join
                   (query-named tinfo1)
                   (query-named tinfo3))
                  (filter-conj
                   (filter-binop = (val-column-ref "users.id") (val-column-ref "posts.user_id"))
                   (filter-binop > (val-column-ref "posts.likes") (val-const 100)))))
(define complex2 (query-select
                  (list (val-column-ref "id") (val-column-ref "name"))
                  (query-join
                   (query-named tinfo1)
                   (query-named tinfo3))
                  (filter-conj
                   (filter-binop = (val-column-ref "users.id") (val-column-ref "posts.user_id"))
                   (filter-binop > (val-column-ref "posts.likes") (val-const 100)))))
(define complex3 (query-select
                  (list (val-column-ref "id") (val-column-ref "name"))
                  (query-join
                   (query-named tinfo1)
                   (query-named tinfo3))
                  (filter-conj
                   (filter-binop = (val-column-ref "users.id") (val-column-ref "posts.user_id"))
                   (filter-binop > (val-column-ref "posts.likes") (val-const 200)))))
(displayln (format "  query-equal? complex1 complex2 (identical): ~a (expected: #t)" (query-equal? complex1 complex2)))
(displayln (format "  query-equal? complex1 complex3 (different constant): ~a (expected: #f)" (query-equal? complex1 complex3)))
(displayln "")

(displayln "=== All tests completed ===")
