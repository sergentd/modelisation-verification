local assert  = require "luassert"
local Adt     = require "adt"
local Boolean = require "adt.boolean"
local Natural = require "adt.natural"

describe ("#natural sort", function ()

  it ("has operations", function ()
    assert.are.equal (getmetatable (Natural.Zero        ), Adt.Operation)
    assert.are.equal (getmetatable (Natural.Successor   ), Adt.Operation)
    assert.are.equal (getmetatable (Natural.Increment   ), Adt.Operation)
    assert.are.equal (getmetatable (Natural.Decrement   ), Adt.Operation)
    assert.are.equal (getmetatable (Natural.Addition    ), Adt.Operation)
    assert.are.equal (getmetatable (Natural.Subtraction ), Adt.Operation)
    assert.are.equal (getmetatable (Boolean.Is_even     ), Adt.Operation)
  end)

  it ("can generate a natural from a number", function ()
    local n = {}
    n [0] = Natural.Zero {}
    n [1] = Natural.Successor { n [0] }
    n [2] = Natural.Successor { n [1] }
    n [3] = Natural.Successor { n [2] }
    assert.are.equal (Natural.nth (3), n [3])
  end)

end)
