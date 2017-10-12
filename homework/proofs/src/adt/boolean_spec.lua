local assert  = require "luassert"
local Adt     = require "adt"
local Boolean = require "adt.boolean"

describe ("#boolean sort", function ()

  it ("defines operations", function ()
    assert.are.equal (getmetatable (Boolean.True    ), Adt.Operation)
    assert.are.equal (getmetatable (Boolean.False   ), Adt.Operation)
    assert.are.equal (getmetatable (Boolean.Equals  ), Adt.Operation)
    assert.are.equal (getmetatable (Boolean.Not     ), Adt.Operation)
    assert.are.equal (getmetatable (Boolean.And     ), Adt.Operation)
    assert.are.equal (getmetatable (Boolean.Or      ), Adt.Operation)
    assert.are.equal (getmetatable (Boolean.Xor     ), Adt.Operation)
    assert.are.equal (getmetatable (Boolean.Implies ), Adt.Operation)
  end)

end)
