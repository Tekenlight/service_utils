local ffi = require('ffi');
local type_utils = {};

type_utils.handle_null = function(value)
    if (ffi.istype("void*", value) and value == ffi.NULL) then
        return nil;
    end
    return value;
end

return type_utils;
