local assert   = require "luassert"
local State    = require "state"
local Fun      = require "fun"
local petrinet = require "petrinet.page47"

describe ("State", function ()

  it ("can be created", function ()
    local state = State.create (petrinet)
    assert.are.equal (getmetatable (state), State)
  end)

  it ("can print a state", function ()
    local state = State.create (petrinet)
    assert.are.equal (tostring (state), [[p1=1,p2=1,p3=0,p4=0,p5=0]])
  end)

  it ("can return the enabled transitions", function ()
    local state = State.create (petrinet)
    local enabled    = state:enabled ()
    assert.are.equal (Fun.length (enabled), 2)
  end)

  it ("can fire a transition", function ()
    local state = State.create (petrinet)
    local s1         = state (petrinet.t1)
    local s2         = state (petrinet.t2)
    local s3         = state (petrinet.t3)
    local s4         = s1 (petrinet.t3)
    local s5         = s2 (petrinet.t3)
    assert.are.equal (getmetatable (s1), State)
    assert.are.equal (getmetatable (s2), State)
    assert.is_nil    (s3)
    assert.are.equal (getmetatable (s4), State)
    assert.is_nil    (s5)
  end)

end)
