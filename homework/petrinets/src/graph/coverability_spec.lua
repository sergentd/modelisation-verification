local assert       = require "luassert"
local Graph        = require "graph"
local Coverability = require "graph.coverability"
local p90          = require "petrinet.page90"
local p92          = require "petrinet.page92"
local p95          = require "petrinet.page95"

describe ("Coverability graph", function ()

  it ("can be created with an implicit traversal", function ()
    local coverability = Coverability.create ()
    assert.are.equal (getmetatable (coverability), Graph)
    assert.are.equal (coverability.traversal, Graph.depth_first)
  end)

  it ("can be created with an explicit traversal", function ()
    local coverability = Coverability.create {
      traversal = Graph.breadth_first,
    }
    assert.are.equal (getmetatable (coverability), Graph)
    assert.are.equal (coverability.traversal, Graph.breadth_first)
  end)

  it ("can compute the coverability graph of a Petri net (depth first)", function ()
    local coverability    = Coverability.create ()
    local initial, states = coverability (p95)
    assert.are.equal (#states, 2)
    local successor = initial.successors [p95.t1]
    assert.is_not_nil (successor)
    assert.is_not_nil (successor.successors [p95.t1])
  end)

  it ("can compute the coverability graph of a Petri net (breadth first)", function ()
    local coverability    = Coverability.create {
      traversal = Graph.breadth_first,
    }
    local initial, states = coverability (p95)
    assert.are.equal (#states, 2)
    assert.is_not_nil (initial.successors [p95.t1])
  end)

  it ("can compute the coverability graph of the page90 problem", function ()
    local coverability = Coverability.create ()
    local _, states    = coverability (p90)
    assert.are.equal (#states, 5)
  end)

  it ("can compute the coverability graph of the page92 problem", function ()
    local coverability = Coverability.create ()
    local _, states    = coverability (p92)
    assert.are.equal (#states, 6)
  end)

end)
