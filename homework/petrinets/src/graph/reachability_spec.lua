local assert       = require "luassert"
local Petrinet     = require "petrinet"
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

  it ("#paper can compute the reachability graph of the paper", function ()
    local reachability = Reachability.create ()
    local _, states    = reachability (require "petrinet.paper")
    local transitions  = {}
    for k, v in pairs (require "petrinet.paper") do
      if getmetatable (v) == Petrinet.Transition then
        transitions [v] = k
      end
    end
    print (#states)
    print "digraph G {"
    for i = 1, #states do
      states [i].id = i
      print ("  s" .. tostring (i) .. ' [label=""];')
    end
    for _, state in ipairs (states) do
      for t, s in pairs (state.successors) do
        print ("  s" .. tostring (state.id) .. " -> s" .. tostring (s.id) .. ' [label="' .. transitions [t] .. '"];')
      end
    end
    print "}"
  end)

end)
