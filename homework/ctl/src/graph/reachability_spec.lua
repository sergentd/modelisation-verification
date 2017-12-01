local assert       = require "luassert"
local Graph        = require "graph"
local Reachability = require "graph.reachability"
local petrinet     = require "petrinet.page47"
local philosophers = require "petrinet.page24"

describe ("Reachability graph", function ()

  it ("can be created with an implicit traversal", function ()
    local reachability = Reachability.create ()
    assert.are.equal (getmetatable (reachability), Graph)
    assert.are.equal (reachability.traversal, Graph.depth_first)
  end)

  it ("can be created with an explicit traversal", function ()
    local reachability = Reachability.create {
      traversal = Graph.breadth_first,
    }
    assert.are.equal (getmetatable (reachability), Graph)
    assert.are.equal (reachability.traversal, Graph.breadth_first)
  end)

  it ("can compute the reachability graph of a Petri net (depth first)", function ()
    local reachability    = Reachability.create ()
    local initial, states = reachability (petrinet)
    assert.are.equal (#states, 5)
    assert.is_not_nil (initial.successors [petrinet.t1])
    assert.is_not_nil (initial.successors [petrinet.t2])
    assert.is_nil     (initial.successors [petrinet.t3])
  end)

  it ("can compute the reachability graph of a Petri net (breadth first)", function ()
    local reachability    = Reachability.create {
      traversal = Graph.breadth_first,
    }
    local initial, states = reachability (petrinet)
    assert.are.equal (#states, 5)
    assert.is_not_nil (initial.successors [petrinet.t1])
    assert.is_not_nil (initial.successors [petrinet.t2])
    assert.is_nil     (initial.successors [petrinet.t3])
  end)

  it ("can compute the reachability graph of the philosophers problem", function ()
    local reachability = Reachability.create ()
    local _, states    = reachability (philosophers (3))
    assert.are.equal (#states, 14)
  end)


end)
