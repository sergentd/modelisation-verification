# Modeling & Verification Homework #5

This repository is the starter for homework #5 of the course
["Modeling & Verification"](https://moodle.unige.ch/course/view.php?id=183)
at [University of Geneva](http://www.unige.ch).

## Environment

Please install the [environment](https://github.com/cui-unige/modeling-verification).
Install also an additional library but running in a terminal the command:

```sh
  luarocks install rockspec/fun-scm-1.rockspec
```

## Subject

You have to complete programs to compute CTL formulas on a reachability or
coverability graph:
* rewrite rules to simplify CTL formulas;
* CTL evaluation.

You must only implement parts shown by `TODO` comments in the source code.
Do **not** touch other algorithms.
You are allowed to add extra functions if needed.

At the beginning, you already have:
* a representation for Petri nets (with tests);
* a representation for their markings (with tests);
* a representation for their states (with tests);
* a parameterized algorithm to compute the reachability and coverability graphs;
* a parameterized algorithm to compute place and transition invariants;
* a representation for ADTs (with tests);
* a representation for CTL formulas, based on ADTs (with tests);
* some Petri nets that can be used in tests.

The ADT module has been slightly modified to accept functions, for the atomic propositions.

## Comments on Code

Modules/classes are in Uppercase, instances are in lowercase.
This homework makes use of the notions seen in the previous homeworks,
you should also look at their documentation.

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

### State

* Each state has a `properties` field,
  that maps CTL formulas to their evaluation (a Boolean value),
  or `nil` if no evaluation has been performed.

### CTL

This module defines an ADT for CTL formulas,
and sets generators for the minimal subset of operators.
It also defines rewrite rules to reduce formulas to their canonical form.


* `Ctl.Expression.*` are operators of the ADT;
* `Ctl.reduce (formula)` returns `formula` translated to its canonical form;
* `Ctl (formula, initial, states)` computes the `formula` on the Reachability
  or coverability graph represented by `initial` and `states`.
  These are returned by the `Graph` module.
  It first reduces the `formula`,
  and then applies `Ctl.compute` to the canonical formula.

### Tests

* All tests are put in `*_spec.lua` files.
* To run only some tests, add a tag to them (for example tag `#test`):

  ```lua
  describe ("#test Place invariants", function () ...
  ```
  And then run from the root of the repository:

  ```sh
  busted --tags=test src/
  ```
