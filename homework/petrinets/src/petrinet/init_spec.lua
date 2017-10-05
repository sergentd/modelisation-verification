local assert   = require "luassert"
local Fun      = require "fun"
local Petrinet = require "petrinet"

describe ("Petri nets", function ()

  it ("can be created", function ()
    local petrinet = Petrinet.create ()
    assert.are.equal (getmetatable (petrinet), Petrinet)
  end)

  it ("can create a place with an implicit marking", function ()
    local petrinet = Petrinet.create ()
    petrinet.p     = petrinet:place  ()
    assert.are.equal (getmetatable (petrinet.p), Petrinet.Place)
    assert.are.equal (petrinet.p.marking, 0)
  end)

  it ("can create a place with an explicit marking", function ()
    local petrinet = Petrinet.create ()
    petrinet.p     = petrinet:place  (5)
    assert.are.equal (getmetatable (petrinet.p), Petrinet.Place)
    assert.are.equal (petrinet.p.marking, 5)
  end)

  it ("can iterate over its places", function ()
    local petrinet = Petrinet.create ()
    petrinet.p     = petrinet:place  (5)
    petrinet.q     = petrinet:place  (0)
    assert.is_truthy (Fun.all (function (place)
      return getmetatable (place), Petrinet.Place
    end, petrinet:places ()))
    assert.are.equal (Fun.length (petrinet:places ()), 2)
  end)

  it ("can create a transition", function ()
    local petrinet = Petrinet.create ()
    petrinet.p     = petrinet:place  ()
    petrinet.q     = petrinet:place  ()
    petrinet.t     = petrinet:transition {
      petrinet.p - 1,
      petrinet.q + 1,
    }
    assert.are.equal (getmetatable (petrinet.t), Petrinet.Transition)
    assert.are.equal (getmetatable (petrinet.t [1]), Petrinet.Arc)
    assert.are.equal (getmetatable (petrinet.t [2]), Petrinet.Arc)
    assert.are.equal (petrinet.t [1].place    , petrinet.p)
    assert.are.equal (petrinet.t [2].place, petrinet.q)
    assert.are.equal (petrinet.t [1].valuation, 1)
    assert.are.equal (petrinet.t [2].valuation, 1)
  end)

  it ("can iterate over its transitions", function ()
    local petrinet = Petrinet.create ()
    petrinet.p     = petrinet:place  ()
    petrinet.q     = petrinet:place  ()
    petrinet.t     = petrinet:transition {
      petrinet.p - 1,
      petrinet.q + 1,
    }
    petrinet.u     = petrinet:transition {
      petrinet.q - 1,
      petrinet.p + 1,
    }
    assert.is_truthy (Fun.all (function (transition)
      return getmetatable (transition), Petrinet.Transition
    end, petrinet:transitions ()))
    assert.are.equal (Fun.length (petrinet:transitions ()), 2)
  end)

  it ("can iterate over pre arcs", function ()
    local petrinet = Petrinet.create ()
    petrinet.p     = petrinet:place  ()
    petrinet.q     = petrinet:place  ()
    petrinet.t     = petrinet:transition {
      petrinet.p - 1,
      petrinet.q + 1,
    }
    assert.is_truthy (Fun.all (function (arc)
      return getmetatable (arc), Petrinet.Arc
    end, petrinet.t:pre ()))
    assert.are.equal (Fun.length (petrinet.t:pre ()), 1)
  end)

  it ("can iterate over post arcs", function ()
    local petrinet = Petrinet.create ()
    petrinet.p     = petrinet:place  ()
    petrinet.q     = petrinet:place  ()
    petrinet.t     = petrinet:transition {
      petrinet.p - 1,
      petrinet.q + 1,
    }
    assert.is_truthy (Fun.all (function (arc)
      return getmetatable (arc), Petrinet.Arc
    end, petrinet.t:post ()))
    assert.are.equal (Fun.length (petrinet.t:post ()), 1)
  end)

end)
