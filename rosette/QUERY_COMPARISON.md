# Direct Structural Comparison of Relational Expressions

## Overview

This module provides direct **structural (syntactic)** comparison functions for relational query expressions in Cosette. These functions compare query AST structures directly, as opposed to the existing semantic comparison that evaluates queries and compares their results.

## Location

- **Implementation**: `rosette/query-equal.rkt`
- **Tests**: `rosette/tests/query-equal-test.rkt`
- **Exports**: Available through `rosette/util.rkt`

## Functions

### `query-equal?`

Compares two query structures for syntactic equality.

```racket
(query-equal? query1 query2) → boolean?
  query1 : query?
  query2 : query?
```

Supports all query types:
- `query-select`
- `query-select-distinct`
- `query-join`
- `query-named`
- `query-rename`
- `query-rename-full`
- `query-left-outer-join`
- `query-union-all`
- `query-aggr-general`

### `val-equal?`

Compares two value expressions for syntactic equality.

```racket
(val-equal? val1 val2) → boolean?
  val1 : val?
  val2 : val?
```

Supports all value types:
- `val-const`
- `val-column-ref`
- `val-aggr-subq`
- `val-bexpr` (binary expressions)
- `val-uexpr` (unary expressions)

### `filter-equal?`

Compares two filter expressions for syntactic equality.

```racket
(filter-equal? filter1 filter2) → boolean?
  filter1 : filter?
  filter2 : filter?
```

Supports all filter types:
- `filter-binop`
- `filter-conj`
- `filter-disj`
- `filter-not`
- `filter-exists`
- `filter-true`
- `filter-false`
- `filter-nary-op`

## Usage Example

```racket
#lang rosette

(require "util.rkt" "syntax.rkt" "cosette.rkt")

; Create two identical query structures
(define tinfo (table-info "users" '("id" "name")))

(define q1 (query-select 
            (list (val-column-ref "id"))
            (query-named tinfo)
            (filter-binop = (val-column-ref "id") (val-const 1))))

(define q2 (query-select 
            (list (val-column-ref "id"))
            (query-named tinfo)
            (filter-binop = (val-column-ref "id") (val-const 1))))

; Structural comparison
(query-equal? q1 q2)  ; => #t

; Create a different query
(define q3 (query-select 
            (list (val-column-ref "name"))  ; different column
            (query-named tinfo)
            (filter-binop = (val-column-ref "id") (val-const 1))))

(query-equal? q1 q3)  ; => #f
```

## Difference from Semantic Comparison

### Structural Comparison (new)
- **What it does**: Compares query AST structures directly
- **Returns true when**: Queries have identical structure and values
- **Fast**: O(n) where n is the size of the AST
- **No evaluation**: Doesn't execute queries or require table data

### Semantic Comparison (existing: `same`, `neq`)
- **What it does**: Evaluates queries and compares results
- **Returns true when**: Queries produce equivalent results
- **Slow**: Requires symbolic execution and SMT solving
- **Requires evaluation**: Needs table data and query evaluation

## Use Cases

1. **Query rewriting verification**: Check if a rewrite preserves the exact query structure
2. **Caching**: Quickly check if a query has been seen before
3. **Deduplication**: Identify duplicate queries without evaluation
4. **Testing**: Verify query transformations produce expected structures
5. **Debugging**: Compare query ASTs during development

## Testing

Run the test suite:

```bash
racket rosette/tests/query-equal-test.rkt
```

The test suite covers:
- All value types
- All filter types
- All query types
- Complex nested queries
- Edge cases

## Notes

- These functions perform **shallow** comparison - they compare the structure but don't simplify or normalize queries
- Two semantically equivalent but structurally different queries will return `#f`
- For semantic equivalence checking, continue using `same` and `neq` functions
