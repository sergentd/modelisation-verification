local assert   = require "luassert"
local Petrinet = require "petrinet"
local Marking  = require "marking"

describe ("Markings", function ()

  it ("can be created from a Petri net", function ()
    local petrinet = Petrinet.create ()
    petrinet.p     = petrinet:place  (1)
    local marking  = Marking.initial (petrinet)
    assert.are.equal (marking [petrinet.p], petrinet.p.marking)
  end)

  it ("can be created from a table", function ()
    local petrinet = Petrinet.create ()
    petrinet.p     = petrinet:place  (1)
    local marking  = Marking.create {
      [petrinet.p] = 2,
    }
    assert.are.equal (marking [petrinet.p], 2)
  end)

  it ("can be compared with ==", function ()
    local petrinet = Petrinet.create ()
    petrinet.p     = petrinet:place  (1)
    petrinet.q     = petrinet:place  (1)
    local r        = petrinet:place  (1)
    local m1       = Marking.initial (petrinet)
    local m2       = Marking.create {
      [petrinet.p] = 1,
      [petrinet.q] = 1,
    }
    local m3       = Marking.create {
      [petrinet.p] = 2,
      [petrinet.q] = 1,
    }
    local m4       = Marking.create {
      [petrinet.p] = 1,
    }
    local m5       = Marking.create {
      [petrinet.p] = 1,
      [petrinet.q] = 1,
      [         r] = 1,
    }
    assert.are    .equal (m1, m2)
    assert.are_not.equal (m1, m3)
    assert.are_not.equal (m1, m4)
    assert.are_not.equal (m1, m5)
  end)

  it ("can be compared with <=", function ()
    local petrinet = Petrinet.create ()
    petrinet.p     = petrinet:place  (1)
    petrinet.q     = petrinet:place  (1)
    local r        = petrinet:place  (1)
    local m1       = Marking.initial (petrinet)
    local m2       = Marking.create {
      [petrinet.p] = 1,
      [petrinet.q] = 1,
    }
    local m3       = Marking.create {
      [petrinet.p] = 0,
      [petrinet.q] = 1,
    }
    local m4       = Marking.create {
      [petrinet.p] = 1,
    }
    local m5       = Marking.create {
      [petrinet.p] = 2,
      [petrinet.q] = 1,
    }
    local m6       = Marking.create {
      [petrinet.p] = 1,
      [petrinet.q] = 1,
      [         r] = 1,
    }
    assert.is_truthy (m2 <= m1)
    assert.is_truthy (m3 <= m1)
    assert.is_truthy (m4 <= m1)
    assert.is_falsy  (m5 <= m1)
    assert.is_falsy  (m6 <= m1)
  end)

  it ("can be compared with <", function ()
    local petrinet = Petrinet.create ()
    petrinet.p     = petrinet:place  (1)
    petrinet.q     = petrinet:place  (1)
    local r        = petrinet:place  (1)
    local m1       = Marking.initial (petrinet)
    local m2       = Marking.create {
      [petrinet.p] = 1,
      [petrinet.q] = 1,
    }
    local m3       = Marking.create {
      [petrinet.p] = 0,
      [petrinet.q] = 1,
    }
    local m4       = Marking.create {
      [petrinet.p] = 1,
    }
    local m5       = Marking.create {
      [petrinet.p] = 2,
      [petrinet.q] = 1,
    }
    local m6       = Marking.create {
      [petrinet.p] = 1,
      [petrinet.q] = 1,
      [         r] = 1,
    }
    assert.is_falsy  (m2 < m1)
    assert.is_truthy (m3 < m1)
    assert.is_truthy (m4 < m1)
    assert.is_falsy  (m5 < m1)
    assert.is_falsy  (m6 < m1)
  end)

  it ("can be added", function ()
    local petrinet = Petrinet.create ()
    petrinet.p     = petrinet:place  (1)
    petrinet.q     = petrinet:place  (1)
    local r        = petrinet:place  (0)
    local m1       = Marking.initial (petrinet)
    local m2       = Marking.create {
      [petrinet.q] = 1,
      [         r] = 1,
    }
    local m3 = m1 + m2
    assert.are.equal (m3, Marking.create {
      [petrinet.p] = 1,
      [petrinet.q] = 2,
      [         r] = 1,
    })
  end)

  it ("can be subtracted", function ()
    local petrinet = Petrinet.create ()
    petrinet.p     = petrinet:place  (1)
    petrinet.q     = petrinet:place  (1)
    local r        = petrinet:place  (0)
    local m1       = Marking.initial (petrinet)
    local m2       = Marking.create {
      [petrinet.q] = 1,
      [         r] = 0,
    }
    local m3 = m1 - m2
    assert.are.equal (m3, Marking.create {
      [petrinet.p] = 1,
      [petrinet.q] = 0,
      [         r] = 0,
    })
  end)

end)
