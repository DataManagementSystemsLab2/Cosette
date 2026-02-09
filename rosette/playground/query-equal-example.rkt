#lang rosette

(require "../util.rkt" "../syntax.rkt" "../cosette.rkt")

;;; Example demonstrating direct structural comparison of relational expressions
;;; This file shows how to use query-equal?, val-equal?, and filter-equal?

(displayln "=== Direct Structural Comparison Example ===")
(displayln "")

;;; Example 1: Comparing simple queries
(displayln "Example 1: Comparing SELECT queries")
(define users-table (table-info "users" '("id" "name" "age")))

(define query1 
  (query-select 
   (list (val-column-ref "id") (val-column-ref "name"))
   (query-named users-table)
   (filter-binop = (val-column-ref "age") (val-const 25))))

(define query2 
  (query-select 
   (list (val-column-ref "id") (val-column-ref "name"))
   (query-named users-table)
   (filter-binop = (val-column-ref "age") (val-const 25))))

(define query3 
  (query-select 
   (list (val-column-ref "id") (val-column-ref "name"))
   (query-named users-table)
   (filter-binop > (val-column-ref "age") (val-const 25))))

(displayln (format "  query1 = SELECT id, name FROM users WHERE age = 25"))
(displayln (format "  query2 = SELECT id, name FROM users WHERE age = 25"))
(displayln (format "  query3 = SELECT id, name FROM users WHERE age > 25"))
(displayln (format "  query-equal? query1 query2: ~a (identical)" (query-equal? query1 query2)))
(displayln (format "  query-equal? query1 query3: ~a (different operator)" (query-equal? query1 query3)))
(displayln "")

;;; Example 2: Comparing JOIN queries
(displayln "Example 2: Comparing JOIN queries")
(define posts-table (table-info "posts" '("id" "user_id" "title")))

(define join1 (query-join (query-named users-table) (query-named posts-table)))
(define join2 (query-join (query-named users-table) (query-named posts-table)))
(define join3 (query-join (query-named posts-table) (query-named users-table)))

(displayln (format "  join1 = users JOIN posts"))
(displayln (format "  join2 = users JOIN posts"))
(displayln (format "  join3 = posts JOIN users"))
(displayln (format "  query-equal? join1 join2: ~a (same order)" (query-equal? join1 join2)))
(displayln (format "  query-equal? join1 join3: ~a (reversed order)" (query-equal? join1 join3)))
(displayln "")

;;; Example 3: Comparing complex filters
(displayln "Example 3: Comparing complex filters")

(define filter1 
  (filter-conj
   (filter-binop > (val-column-ref "age") (val-const 18))
   (filter-binop < (val-column-ref "age") (val-const 65))))

(define filter2 
  (filter-conj
   (filter-binop > (val-column-ref "age") (val-const 18))
   (filter-binop < (val-column-ref "age") (val-const 65))))

(define filter3 
  (filter-conj
   (filter-binop >= (val-column-ref "age") (val-const 18))  ; note: >= instead of >
   (filter-binop < (val-column-ref "age") (val-const 65))))

(displayln (format "  filter1 = age > 18 AND age < 65"))
(displayln (format "  filter2 = age > 18 AND age < 65"))
(displayln (format "  filter3 = age >= 18 AND age < 65"))
(displayln (format "  filter-equal? filter1 filter2: ~a" (filter-equal? filter1 filter2)))
(displayln (format "  filter-equal? filter1 filter3: ~a (different operator)" (filter-equal? filter1 filter3)))
(displayln "")

;;; Example 4: Comparing value expressions
(displayln "Example 4: Comparing value expressions")

(define expr1 (val-bexpr + (val-column-ref "salary") (val-const 1000)))
(define expr2 (val-bexpr + (val-column-ref "salary") (val-const 1000)))
(define expr3 (val-bexpr * (val-column-ref "salary") (val-const 1.1)))

(displayln (format "  expr1 = salary + 1000"))
(displayln (format "  expr2 = salary + 1000"))
(displayln (format "  expr3 = salary * 1.1"))
(displayln (format "  val-equal? expr1 expr2: ~a" (val-equal? expr1 expr2)))
(displayln (format "  val-equal? expr1 expr3: ~a (different operation)" (val-equal? expr1 expr3)))
(displayln "")

;;; Example 5: Use case - Query caching
(displayln "Example 5: Use case - Query caching")
(displayln "  Structural comparison can be used for query caching:")
(define cache (make-hash))

(define (cached-execute query)
  (if (hash-has-key? cache query)
      (begin
        (displayln "    -> Cache HIT!")
        (hash-ref cache query))
      (begin
        (displayln "    -> Cache MISS, executing query...")
        (let ([result "query-result"])  ; placeholder
          (hash-set! cache query result)
          result))))

(displayln (format "  First execution of query1:"))
(cached-execute query1)
(displayln (format "  Second execution of query1 (identical structure):"))
(cached-execute query1)
(displayln (format "  Execution of query3 (different structure):"))
(cached-execute query3)
(displayln "")

(displayln "=== Key Takeaway ===")
(displayln "Structural comparison (query-equal?) checks if two queries have")
(displayln "the exact same AST structure, without evaluating them.")
(displayln "")
(displayln "This is different from semantic comparison (same/neq) which")
(displayln "evaluates queries and checks if they produce equivalent results.")
