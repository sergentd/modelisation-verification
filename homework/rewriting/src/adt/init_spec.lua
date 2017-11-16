local assert  = require "luassert"
local Adt     = require "adt"

describe ("#adt", function ()

  it ("can create a sort", function ()
    local sort = Adt.Sort "sort"
    assert.are.equal (getmetatable (sort), Adt.Sort)
  end)

  it ("can print a sort", function ()
    local sort = Adt.Sort "sort"
    assert.are.equal (tostring (sort), "sort")
  end)

  it ("can check if two sorts are equal", function ()
    local s1 = Adt.Sort "sort"
    local s2 = Adt.Sort "sort"
    assert.are_not.equal (s1, s2)
  end)

  it ("can try to access __pairs on a sort", function ()
    local sort = Adt.Sort "sort"
    assert.is_nil (sort.__pairs)
  end)

  it ("can create a variable", function ()
    local sort     = Adt.Sort "sort"
    local variable = Adt.Variable {
      [Adt.Sort] = sort,
      [Adt.name] = "v",
    }
    assert.are.equal (getmetatable (variable), Adt.Variable)
  end)

  it ("can create a variable from a sort", function ()
    local sort     = Adt.Sort "sort"
    local variable = sort._v
    assert.are.equal (getmetatable (variable), Adt.Variable)
  end)

  it ("can print a variable", function ()
    local sort     = Adt.Sort "sort"
    local variable = sort._v
    assert.are.equal (tostring (variable), "v: sort")
  end)

  it ("can check if two variables are equal", function ()
    local sort = Adt.Sort "sort"
    local v1   = sort._v
    local v2   = sort._v
    local v3   = sort._w
    assert.are    .equal (v1, v2)
    assert.are_not.equal (v1, v3)
  end)

  it ("can create an operation from a sort", function ()
    local sort     = Adt.Sort "sort"
    sort.operation = {}
    assert.are.equal (getmetatable (sort.operation), Adt.Operation)
  end)

  it ("can print an operation", function ()
    local sort     = Adt.Sort "sort"
    local s1       = Adt.Sort "s1"
    sort.operation = { sort, s1 }
    assert.are.equal (tostring (sort.operation), "operation { 1: sort, 2: s1 }: sort")
  end)

  it ("can check if two operations are equal", function ()
    local sort = Adt.Sort "sort"
    local s1   = Adt.Sort "s1"
    local s2   = Adt.Sort "s2"
    sort.o1 = { sort, s1 }
    sort.o2 = { s2 }
    assert.are    .equal (sort.o1, sort.o1)
    assert.are_not.equal (sort.o1, sort.o2)
  end)

  it ("can create a term from an operation", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local term = sort.cons { sort.empty {} }
    assert.are.equal (getmetatable (term), Adt.Term)
  end)

  it ("can print a term", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local term = sort.cons { sort.empty {} }
    assert.are.equal (tostring (term), "cons { 1 = empty: sort }: sort")
  end)

  it ("can check if two terms are equal", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local t1 = sort.cons { sort.empty {} }
    local t2 = sort.cons { sort.empty {} }
    local t3 = sort.empty {}
    local t4 = sort.cons { sort._v }
    assert.are    .equal (t1, t2)
    assert.are_not.equal (t1, t3)
    assert.are_not.equal (t1, t4)
  end)

  it ("can check if two terms equivalent", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local composite = Adt.Sort "composite"
    composite.create = { sort, sort }
    local t1 = sort.cons { sort.empty {} }
    local t2 = sort.cons { sort.empty {} }
    local t3 = sort.empty {}
    local t4 = sort.cons { sort._v }
    assert.is_truthy (Adt.Term.equivalence (t1, t2))
    assert.is_falsy  (Adt.Term.equivalence (t1, t3))
    assert.is_truthy (Adt.Term.equivalence (t1, t4))
    assert.is_truthy (Adt.Term.equivalence (t2, t1))
    assert.is_falsy  (Adt.Term.equivalence (t3, t1))
    assert.is_truthy (Adt.Term.equivalence (t4, t1))
    local t5 = composite.create { t1, t2 }
    local t6 = composite.create { t1, t3 }
    local t7 = composite.create { sort._v, sort._v }
    local t8 = composite.create { sort._v, sort._w }
    assert.is_falsy  (Adt.Term.equivalence (t3, t5))
    assert.is_truthy (Adt.Term.equivalence (t5, t7))
    assert.is_truthy (Adt.Term.equivalence (t5, t8))
    assert.is_falsy  (Adt.Term.equivalence (t5, t6))
    assert.is_falsy  (Adt.Term.equivalence (t6, t7))
    assert.is_truthy (Adt.Term.equivalence (t6, t8))
    assert.is_falsy  (Adt.Term.equivalence (t7, t8))
    assert.is_falsy  (Adt.Term.equivalence (t5, t3))
    assert.is_falsy  (Adt.Term.equivalence (t6, t5))
    assert.is_truthy (Adt.Term.equivalence (t7, t5))
    assert.is_falsy  (Adt.Term.equivalence (t7, t6))
    assert.is_truthy (Adt.Term.equivalence (t8, t5))
    assert.is_truthy (Adt.Term.equivalence (t8, t6))
    assert.is_falsy  (Adt.Term.equivalence (t8, t7))
  end)

  it ("can get the equivalence mapping between two terms", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local composite = Adt.Sort "composite"
    composite.create = { sort, sort }
    local t1 = sort.cons { sort.empty {} }
    local t2 = sort.cons { sort._v }
    local t3 = sort._v
    local t4 = sort.empty {}
    do
      local ok, map = Adt.Term.equivalence (t1, t1)
      assert.is_truthy (ok)
      assert.are.same (map, {})
    end
    do
      local ok, map = Adt.Term.equivalence (t1, t2)
      assert.is_truthy (ok)
      assert.are.same (map, {
        [sort._v] = sort.empty {},
      })
    end
    do
      local ok, map = Adt.Term.equivalence (t2, t2)
      assert.is_truthy (ok)
      assert.are.same (map, {
        [sort._v] = sort._v,
      })
    end
    do
      local ok, map = Adt.Term.equivalence (t1, t3)
      assert.is_truthy (ok)
      assert.are.same (map, {
        [sort._v] = sort.cons { sort.empty {} },
      })
    end
    local t5 = composite.create { t1, t1 }
    local t6 = composite.create { t1, t4 }
    local t7 = composite.create { sort._v, sort._v }
    local t8 = composite.create { sort._v, sort._w }
    do
      local ok, map = Adt.Term.equivalence (t5, t5)
      assert.is_truthy (ok)
      assert.are.same (map, {})
    end
    do
      local ok, map = Adt.Term.equivalence (t5, t7)
      assert.is_truthy (ok)
      assert.are.same (map, {
        [sort._v] = t1,
      })
    end
    do
      local ok, map = Adt.Term.equivalence (t5, t8)
      assert.is_truthy (ok)
      assert.are.same (map, {
        [sort._v] = t1,
        [sort._w] = t1,
      })
    end
    do
      local ok, map = Adt.Term.equivalence (t6, t8)
      assert.is_truthy (ok)
      assert.are.same (map, {
        [sort._v] = t1,
        [sort._w] = t4,
      })
    end
  end)

  it ("can replace variables in terms", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local t1 = sort.cons { sort._v }
    local t2 = sort.empty {}
    assert.are.equal (t1 / { [sort._v] = t2 }, sort.cons { sort.empty {} })
  end)

  it ("can create an rule from two terms", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local t1 = sort.cons { sort.empty {} }
    local t2 = sort.empty {}
    local rule = Adt.Rule { t1, t2 }
    assert.are.equal (getmetatable (rule), Adt.Rule)
  end)

  it ("can create an rule from two terms and a guard", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local t1 = sort.cons { sort.empty {} }
    local t2 = sort.empty {}
    local rule = Adt.Rule { t1, t2, when = t2 }
    assert.are.equal (getmetatable (rule), Adt.Rule)
  end)

  it ("can print an rule", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local t1 = sort.cons { sort.empty {} }
    local t2 = sort.empty {}
    local rule = Adt.Rule { t1, t2, when = t2 }
    assert.are.equal (tostring (rule), "cons { 1 = empty: sort }: sort = empty: sort when empty: sort")
  end)

  it ("can check if two rules are equal", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local t1 = sort.cons { sort.empty {} }
    local t2 = sort.empty {}
    local r1 = Adt.Rule { t1, t2, when = t2 }
    local r2 = Adt.Rule { t1, t2 }
    local r3 = Adt.Rule { t2, t1 }
    assert.are    .equal (r1, r1)
    assert.are_not.equal (r1, r2)
    assert.are_not.equal (r1, r3)
  end)

  it ("can create and apply a fail strategy", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local t1 = sort.cons { sort.empty {} }
    local s1 = Adt.Strategy.fail
    assert.is_nil (s1 (t1))
  end)

  it ("can create and apply an identity strategy", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local t1 = sort.cons { sort.empty {} }
    local s1 = Adt.Strategy.identity
    assert.are.equal (getmetatable (s1), Adt.Strategy)
    assert.are.equal (s1 (t1), t1)
  end)

  it ("can create and apply a strategy from a rule", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local t1 = sort.cons { sort.empty {} }
    local t2 = sort.empty {}
    local r1 = Adt.Rule { t1, t2 }
    local s1 = Adt.Strategy.rule (r1)
    assert.are.equal (getmetatable (s1), Adt.Strategy)
    assert.are.equal (s1 (t1), t2)
  end)

  it ("can create and apply a sequence strategy", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local t1 = sort.empty {}
    local r1 = Adt.Rule { sort._x, sort.cons { sort._x } }
    local s1 = Adt.Strategy.rule (r1)
    local s2 = Adt.Strategy.sequence { s1, s1 }
    assert.are.equal (getmetatable (s2), Adt.Strategy)
    assert.are.equal (s2 (t1), sort.cons { sort.cons { sort.empty {} } })
  end)

  it ("can create and apply a choice strategy", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local t1 = sort.empty {}
    local s1 = Adt.Strategy.choice { Adt.Strategy.fail, Adt.Strategy.fail         }
    local s2 = Adt.Strategy.choice { Adt.Strategy.fail, Adt.Strategy.identity     }
    local s3 = Adt.Strategy.choice { Adt.Strategy.identity, Adt.Strategy.fail     }
    assert.are.equal (getmetatable (s1), Adt.Strategy)
    assert.are.equal (getmetatable (s2), Adt.Strategy)
    assert.are.equal (getmetatable (s3), Adt.Strategy)
    assert.is_nil (s1 (t1))
    assert.are.equal (s2 (t1), t1)
    assert.are.equal (s3 (t1), t1)
  end)

  it ("can create and apply a all strategy", function ()
    local sort = Adt.Sort "sort"
    sort.empty  = {}
    sort.unary  = { sort }
    sort.binary = { sort, sort }
    local t1 = sort.binary { sort.empty {}, sort.empty {} }
    local r1 = Adt.Rule { sort._x, sort.unary { sort._x } }
    local s1 = Adt.Strategy.all (Adt.Strategy.rule (r1))
    assert.are.equal (getmetatable (s1), Adt.Strategy)
    assert.are.equal (s1 (t1), sort.binary { sort.unary { sort.empty {} }, sort.unary { sort.empty {} } })
  end)

  it ("can create and apply a one strategy", function ()
    -- TODO
  end)

  it ("can create and apply a try strategy", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local t1 = sort.empty {}
    local r1 = Adt.Rule { sort._x, sort.cons { sort._x } }
    local s1 = Adt.Strategy.try (Adt.Strategy.fail)
    local s2 = Adt.Strategy.try (Adt.Strategy.rule (r1))
    assert.are.equal (getmetatable (s1), Adt.Strategy)
    assert.are.equal (getmetatable (s2), Adt.Strategy)
    assert.are.equal (s1 (t1), t1)
    assert.are.equal (s2 (t1), sort.cons { sort.empty {} })
  end)

  it ("can create and apply a fixpoint strategy", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local t1 = sort.cons { sort.cons { sort.empty {} } }
    local r1 = Adt.Rule { sort.cons { sort._x }, sort._x }
    local s1 = Adt.Strategy.fixpoint (Adt.Strategy.rule (r1))
    assert.are.equal (getmetatable (s1), Adt.Strategy)
    assert.are.equal (s1 (t1), sort.empty {})
  end)

  it ("can create and apply a bottomup strategy", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local t1 = sort.cons { sort.cons { sort.empty {} } }
    local r1 = Adt.Rule { sort.cons { sort._x }, sort._x }
    local s1 = Adt.Strategy.bottomup (Adt.Strategy.try (Adt.Strategy.rule (r1)))
    assert.are.equal (getmetatable (s1), Adt.Strategy)
    assert.are.equal (s1 (t1), sort.empty {})
  end)

  it ("can create and apply a topdown strategy", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local t1 = sort.cons { sort.cons { sort.empty {} } }
    local r1 = Adt.Rule { sort.cons { sort._x }, sort._x }
    local s1 = Adt.Strategy.topdown (Adt.Strategy.try (Adt.Strategy.rule (r1)))
    assert.are.equal (getmetatable (s1), Adt.Strategy)
    assert.are.equal (s1 (t1), sort.cons { sort.empty {} })
  end)

  it ("can create and apply a innermost strategy", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local t1 = sort.cons { sort.cons { sort.empty {} } }
    local r1 = Adt.Rule { sort.cons { sort._x }, sort._x }
    local s1 = Adt.Strategy.innermost (Adt.Strategy.rule (r1))
    assert.are.equal (getmetatable (s1), Adt.Strategy)
    assert.are.equal (s1 (t1), sort.empty {})
  end)

  it ("can create and apply a outermost strategy", function ()
    local sort = Adt.Sort "sort"
    sort.empty = {}
    sort.cons  = { sort }
    local t1 = sort.cons { sort.cons { sort.empty {} } }
    local r1 = Adt.Rule { sort.cons { sort._x }, sort._x }
    local s1 = Adt.Strategy.outermost (Adt.Strategy.rule (r1))
    assert.are.equal (getmetatable (s1), Adt.Strategy)
    assert.are.equal (s1 (t1), sort.empty {})
  end)

end)
