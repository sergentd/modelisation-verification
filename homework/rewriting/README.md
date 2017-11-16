# Modeling & Verification Homework #4

This repository is the starter for homework #4 of the course
["Modeling & Verification"](https://moodle.unige.ch/course/view.php?id=183)
at [University of Geneva](http://www.unige.ch).

## Environment

Please install the [environment](https://github.com/cui-unige/modeling-verification).
Install also an additional library but running in a terminal the command:

```sh
  luarocks install rockspec/fun-scm-1.rockspec
  luarocks install rockspec/hashids-scm-1.rockspec
```

## Subject

You have to complete programs to check proofs on ADTs:

* write rules for all operations in `adt/boolean.lua`;
* write rules for all operations in `adt/natural.lua`;
* complete strategy generators in `adt/init.lua`;
* create an ADT that will test correctly all the strategies;
  it must be non-confluent to allow your tests to distinguish `innermost`
  and `outermost` for instance.

You must only implement parts shown by `TODO` comments in the source code.
Do **not** touch other algorithms.
You are allowed to add extra functions if needed.

At the beginning, you already have:

* a representation for Algebraic Abstract Data Types (with tests);
* a representation for rewrite rules and strategies;
* parts of the Boolean and Natural data types;
* some strategy generators.

## Comments on Code

Modules/classes are in Uppercase, instances are in lowercase.
Look at tests! They are provided not only to check your code,
but also to show you examples of use of classes and methods.

### Iterators and Functions

We use [luafun](https://github.com/rtsisyk/luafun) to manipulate collections
and iterators.

* `Fun.all (predicate, iterator)` checks that all elements in `iterator`
  match `predicate`.
* `Fun.each (function, iterator)` applies `function` to all elements in
  `iterator`.
* `Fun.map (function, iterator)` applies `function` to all elements in
  `iterator` and returns an iterator over the results.
  If `function` returns one result, the iterator contains only values.
  If `function` returns two results, the iterator contains key-value pairs.
* `Fun.totable (iterator)` returns a Lua table built from elements in an
  `iterator` that contains only values.
  Elements in the table are indexed by numbers, starting at 1.
* `Fun.tomap (iterator)` returns a Lua table built from elements in an
  `iterator` that contains keys and values.
  Elements in the table are indexed by keys.
* Other functions to discover in the documentation!
* Methods can be chained, for instance: `Fun.frommap (t):map (...):tomap ()`.

### Algebraic Abstract Data Types

The `Adt` module contains the following "classes":

* `Sort` to represent sorts;
* `Variable` to represent variables;
* `Operation` to represent operations (and generators);
* `Term` to represent terms;
* `Rule` to represent rewrite rules;
* `Strategy` to represent strategies.

### Sort

* `Sort "sort"` returns a new sort that will be printed "sort".
* `sort [Adt.name]` returns the name of `sort`.
* `sort [Adt.rules]` returns a table that stores the rules for `sort`.
* `getmetatable (sort) == Adt.Sort` tests if `sort` is a sort.
* `tostring (sort)` returns a string representation of `sort`.
* `sort_1 == sort_2` tests if the two sorts are the same one.

### Variable

* `sort._variable` returns the variable `variable` of sort `sort`.
* `getmetatable (variable) == Adt.Variable` tests if `variable` is a variable.
* `tostring (variable)` returns a string representation of `variable`.
* `variable_1 == variable_2` tests if the two variables are the same one.
* `variable [Adt.Sort]` returns the sort of `variable`.
* `variable / mapping` returns a new term or variable that corresponds
  to `variable` where it has been replaced by what is given in `mapping`.
  `mapping` is a table that maps variables to terms or variables.
  It can be obtained by `Adt.Term.equivalence`.

### Operation

* `sort.operation = { ... }` creates a new operation with operator `operation`
  in `sort`. The result of `operation` is of type `sort` and its operands are
  listed in the table, that represents the parameters of the operation and
  their sorts.
  This table can be of the form `{ sort_1, sort_2, ... }`, of the form
  `{ key_1 = sort_1, key_2 = sort_2, ... }` or a mix of these two forms.
* `getmetatable (operation) == Adt.Operation` tests if `operation` is an
  operation.
* `tostring (operation)` returns a string representation of `operation`.
* `operation_1 == operation_2` tests if the two operations are the same one.
* `operation [Adt.Sort]` returns the sort of `operation`.
* `operation { ... }` returns a term built using `operation`.
  This term is of the sort of `operation` and has the parameters passed in
  the table operand as arguments.
  This table can be of the form `{ term_1, term_2, ... }`, of the form
  `{ key_1 = term_1, key_2 = term_2, ... }` or a mix of these two forms.
  The terms must be of the sort described in the table passed at the creation
  of `operation`.

An iteration over the operands of an operation is usually written as below.
The `filter` is used to not take into account the `operation [Adt.Sort]` field.
```lua
result = Fun.frommap (operation)
       : filter (function (k) return type (k) ~= "table" end)
       : map (function (k, v) ... end)
  -- or all  (function (k, v) ... end)
  -- or each (function (k, v) ... end)
```

### Term

* Terms also have the following methods:
* `getmetatable (term) == Adt.Term` tests if `term` is a term.
* `tostring (term)` returns a string representation of `term`.
* `term_1 == term_2` tests if the two terms are equal.
* `term [Adt.Sort]` returns the sort of `term`.
* `term [Adt.Operation]` returns the operation of `term`.
* `ok, mapping = Adt.Term.equivalence (term_1, term_2)` tests if the two
  terms are equivalent, with a renaming of their variables.
  It returns two values, a boolean `ok` that is true if the terms are
  equivalent, and a `mapping` from variables to terms or variables, that
  can be used to rename variables in `term_1` and `term_2`.
* `term / mapping` returns a new term that corresponds to `term` where
  variables have been replaced by what is given in `mapping`.
  `mapping` is a table that maps variables to terms or variables.
  It can be obtained by `Adt.Term.equivalence`.

An iteration over the operands of a term is usually written similarly as below.
The `filter` is used to not take into account the `term [Adt.Sort]`
and `term [Adt.Operation]` fields.
```lua
result = Fun.frommap (term)
       : filter (function (k) return type (k) ~= "table" end)
       : map (function (k, v) ... end)
  -- or all  (function (k, v) ... end)
  -- or each (function (k, v) ... end)
```

The transformation of a term is usually written as below.
It obtains the term operation with `term [Operation]`,
and then calls it with the new term contents.
```lua
result = term [Operation] (Fun.frommap (term)
       : filter  (function (k, _) return type (k) ~= "table" end)
       : map     (function (k, v) ... end)
       : tomap ())
```

### Rule

* `Adt.rule { lhs, rhs, when = when }` returns an rule of the form
  `when => lhs = rhs`.
   The `when` parameter is optional, but must be of `Boolean` sort if given.
   It differs from the slides, when a condition is a conjunction of
   term equalities.
* `sort [Adt.Rules].myrule = Adt.rule { ... }` allows to store the rule
  with key `myrule`.
* `getmetatable (rule) == Adt.Rule` tests if `rule` is an rule.
* `tostring (rule)` returns a string representation of `rule`.
* `rule_1 == rule_2` tests if the two rules are equal.

### Strategies

* `Strategy (f)` creates a new strategy, where `f` is a function that
  takes a term (or a variable, or `nil`) and returns the transformed term,
  or `nil` if the strategy does not apply on the term.
* `strategy (term)` applies `strategy` on `term`. It returns either a new term
  or `nil` in case of failure.
* `Strategy.fail` is the fail strategy.
* `Strategy.identity` is the identity strategy.
* `Strategy.rule (rule)` returns a strategy that applies the rewriting rule
  `rule` to the terms.
* Other strategies are named as in the course, except repeat that has been
  named `fixpoint`.
* `Strategy.recursive (f)` creates a recursive strategy. Its parameter `f` is
  a function that takes as unique parameter the current strategy (named `x` in
  the course), and returns the created strategy. For instance:

  ```lua
  function Strategy.fixpoint (s)
    assert (getmetatable (s) == Strategy,
            "parameter must be a strategy")
    return Strategy.recursive (function (r)
      return Strategy.choice { Strategy.sequence { s, r }, Strategy.identity }
    end)
  end
  ```

## Tests

* All tests are put in `*_spec.lua` files.
* To run only some tests, add a tag to them (for example tag `#test`):

  ```lua
  describe ("#test ...", function () ...
  ```

  And then run from the root of the repository:

  ```
  $ busted --tags=test src/
  ```
