# Modeling & Verification Homework #6

This repository is the starter for homework #6 of the course
["Modeling & Verification"](https://moodle.unige.ch/course/view.php?id=183)
at [University of Geneva](http://www.unige.ch).

## Environment

Please install the [environment](https://github.com/cui-unige/modeling-verification).
Install also an additional library but running in a terminal the command:

```sh
  luarocks install rockspec/fun-scm-1.rockspec
```

## Subject

You have to complete programs to use decision diagrams to compute the state
space of Petri nets.

You must only implement parts shown by `FIXME` comments in the source code.
Do **not** touch other algorithms.
You are allowed to add extra functions if needed.

At the beginning, you already have:
* a representation for Petri nets (with tests);
* a representation for decision diagrams;
* a representation for decision diagram operations;
* some Petri nets that can be used in tests.

The Petri nets have been modified from the implementation of Homework #1.
We only consider 1-safe Petri nets, where markings are represented as Boolean
values.
We also only consider Binary Decision Diagrams, where terminals are Boolean
values, and arcs are also valued by Booleans.
Operations are taken from Data/Set/Sigma Decision Diagrams.

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

### Petri net

Examples of Petri nets are given in files `page*.lua`.

* `Petrinet.create ()` returns a new Petri net.
* `petrinet:place (marking)` returns a new place with initial `marking`.
  This place must be stored within the Petri net to be considered.
  The marking is a Boolean value.
* `petrinet:places ()` returns an iterator over the places of the Petri net.
  Each place contains a `marking` field with its initial marking.
* `petrinet:transition (t)` returns a new transition with arcs described in `t`.
  This transition must be stored within the Petri net to be considered.
  `t` is a table that maps places to the arc valuation (negative for pre arcs,
  positive for post arcs).
* `petrinet:transitions ()` returns an iterator over the transitions of the
  Petri net.
  Each transition contains the mapping given as parameter `t` when it was built.
* `transition:pre ()` returns an iterator over the pre arcs of the transition.
  Each arc contains a `place` field that stores the input place,
  and a `valuation` field that stores the arc valuation (a positive number).
* `transition:post ()` returns an iterator over the post arcs of the transition.
  Each arc contains a `place` field that stores the output place,
  and a `valuation` field that stores the arc valuation (a positive number).

### Decision diagrams

* `local Dd = require "dd" (variables)` returns an instance of the module configured
  for `variables`. This parameter is a table of variables, sorted from the
  top one to the bottom one (nearest to the terminal).
* `Dd.terminal (v)` returns a new terminal with value `v` (a Boolean).
  This terminal is unique: two terminals with the same value are represented
  by the same object.
* `Dd.node { variable = v, [true] = t, [false] = f }` returns a new node
  with variable `v`, `true` arc leading to node or terminal `t`, and `false`
  arc leading to `f`.
  This node is unique: two nodes with the same variable and successors are
  represented by the same object.
  Moreover, this node has been applied the don't care reduction.
* `Dd.create (t)` returns a new decision diagram that has only one path
  leading to terminal `true`.
  `t` is a table that maps variables to their value for the `true` path.
* `Dd.paths (x)` returns the paths of decision diagram `x`.
  Paths are a table (indexed from 1 to n) of tables that map the variables
  to their value (or `nil` if the variable does not appear because of a
  don't care).
  *Warning:* because of `nil`s, one path can represent several states.
* `Dd.show (x)`, where `x` is a decision diagram or the result of `Dd.paths`
  prints the paths of the decision diagram.
* `Dd.dontcare (dd)` applies the don't care reduction to `dd`,
  and returns the reduced decision diagram.
* `Dd.unique (dd)` searches for existing decision diagrams that are the same
  as `dd`. If found, the already existing one is returned.
  This ensures decision diagram uniqueness, and is thus called by
  `Dd.terminal`, `Dd.node` and `Dd.create`.
* The `==` operator is defined on nodes and terminals.
* `tostring (x)` is defined on nodes and terminals. It returns the unique
  identifier for nodes and terminals, and the terminal value or the node
  variable and successors.
* `+, *, -` are defined as `__add`, `__mul` and `__sub` methods for nodes
  and terminals. They are respectively union, intersection and difference
  operations.

This representation for decision diagrams is *not* efficient, because we
do not implement caching mechanisms for union/intersection/difference.

### Decision diagram operations

We use operations inspired from Data/Set/Sigma decision diagrams.
Inductive operations are not covered for simplicity.

Operations are objects that can be applied on one decision diagram,
and return one decision diagram.
Operations can be parameterized, for instance `Constant (dd)`,
`Fixpoint (o)`, or `Union (...)` are parameterized by `dd`, `o`, ...

Examples of usage are given in tests.

* `Dd.constant (dd)` returns an operation that always returns the `dd` decision
  diagram.
* `Dd.identity ()` returns an operation that always returns its operand.
* `Dd.filter (f)` returns an operation that filters paths of its operand.
  It applies `f` to all paths of the decision diagram and keeps only the
  paths where `f` returns `true`.
  Paths are given as a mapping from variables to values, as in `Dd.create`.
* `Dd.map (f)` returns an operation that updates paths of its operand.
  It applies `f` to all paths of the decision diagram and updates the path
  with the result of `f`.
  Paths are given as a mapping from variables to values, as in `Dd.create`.
* `Dd.composition (t)` returns the composition of the suboperations given in
  table `t`. This table is indexed by 1..n and contains as values the
  suboperations to apply, sorted from the first to apply to last one.
* `Dd.union (t)`, `Dd.intersection (t)`, `Dd.difference (t)`
  returns the union or intersection or difference of
  the results of suboperations given in table `t`.
  Table `t` is indexed by 1..n and contains as values the
  suboperations to apply, sorted from the first to apply to last one.
* `Fixpoint (o)` returns a fixed point of operation `o`:
  it applies `o` on its parameter until nothing changes anymore.
* `+, *, -` are defined as `__add`, `__mul` and `__sub` methods for operations.
  They are respectively union, intersection and difference operations.
* `..` is defined as the `__concat` method for operations.
  It is the composition operation.
  `x .. y` is the same as `Dd.composition { x, y }`.

This representation for decision diagrams is *not* efficient, because we
do not implement caching mechanisms for operations.


### Decision diagram for Petri nets

The `dd.petrinet` module computes state spaces of Petri nets using decision
diagrams.
It takes a Petri net as parameter, and returns a wrapper around the `Dd` module
adapted to the Petri net given as parameter.

This wrapper also contains three fields:

* `variables` is the variables order, that contains the places of the Petri net;
* `initial` is a decision diagram representing the initial state of the Petri net;
* `generate` is a decision diagram operation that generates the state space of the Petri net.

Examples of usage are given in tests.

### Tests

* All tests are put in `*_spec.lua` files.
* To run only some tests, add a tag to them (for example tag `#test`):

  ```lua
  describe ("#test something", function () ...
  ```
  And then run from the root of the repository:

  ```sh
  busted --tags=test src/
  ```
