local bc = require("bc");
local decimal = {};

local is_type = function(x)
    return (x and getmetatable(x).__name == 'bc bignumber');
end

decimal.new = function(x)
    assert(type(x) == 'number' or type(x) == 'string');
    return bc.new(x);
end

decimal.ceil = function(x)
    assert(is_type(x), "Invalid decimal input");
    local digits = bc.digits();
    bc.digits(0);
    local comp = (x>(x/1));
    if (comp == true) then
        comp = 1;
    else
        comp = 0;
    end
    local out = ((x/1) + bc.new(comp) );

    local s_out = tostring(out);
    out = bc.new(s_out);
    bc.digits(digits);
    return out;
end


decimal.floor = function(x)
    assert(is_type(x), "Invalid decimal input");
    local digits = bc.digits();
    bc.digits(0);
    local a = x;
    local out;
    if (a < 0 and a ~= (a/bc.new(1))) then
        out = (a/1) - 1;
    else
        out = a / 1;
    end

    local s_out = tostring(out);
    out = bc.new(s_out);
    bc.digits(digits);
    return out;
end

decimal.round = function(x, n)
    assert(is_type(x), "Invalid decimal input");
    if (n == nil) then n = 0; end
    assert(type(n) == "number", "Invalid inputs");


    local digits = bc.digits();
    local scale = n+1;
    bc.digits(scale)

    local ten = bc.new("10");
    local half = bc.new("0.5");

    local a = (x*(ten^n)) + half; 

    local out = a/(ten ^ n);
    bc.digits(n)
    local s_out = tostring(out);
    out = bc.new(s_out);
    bc.digits(digits);
    return out;
end

--[[
bc.digits(4);
print("ceil(5.7)", decimal.ceil(bc.new("5.7")));
print("floor(5.7)", decimal.floor(bc.new("5.7")));
print("round(5.7)", decimal.round(bc.new("5.7")));
print("round(5.3)", decimal.round(bc.new("5.3")));
print("round(5.3789, 2)", decimal.round(bc.new("5.3789"), 2));
print("zero", decimal.new(0));
print("half", decimal.new(0.5));
print("one", decimal.new(1));
print("ten", decimal.new(10));
]]

return decimal;
