local msg_literal = {};

local ffi = require('ffi');

ffi.cdef[[
int sprintf(char * restrict str, const char * restrict format, ...);
void free(void *ptr);
void * memset(void *b, int c, size_t len);
int snprintf(char * restrict str, size_t size, const char * restrict format, ...);
]]

function msg_literal:format_with_string(str, ...)
	if (str == nil) then
		error("LITERAL REQUIRED");
		return nil;
	end
	local args = {...};
	local new_args = {};
	for i,v in ipairs(args) do
		new_args[i] = tostring(args[i]);
	end
	local c_str = ffi.new("char [?]", 1024);
	ffi.C.memset(c_str, 0, 1024);
	ffi.C.snprintf(c_str, 1024, str, table.unpack(new_args));
	return ffi.string(c_str);
end

function msg_literal:format(id, ...)
	local str = self.list[id];
	if (str == nil) then
		error("LITERAL ID NOT FOUND");
		return nil;
	end
	return self:format_with_string(str, ...);
end

function msg_literal:old_format(id, ...)
	local str = self.list[id];
	if (str == nil) then
		error("LITERAL ID NOT FOUND");
		return nil;
	end
	local args = {...};
	local new_args = {};
	for i,v in ipairs(args) do
		new_args[i] = tostring(args[i]);
	end
	local c_str = ffi.new("char [?]", 1024);
	ffi.C.memset(c_str, 0, 1024);
	ffi.C.snprintf(c_str, 1024, str, table.unpack(new_args));
	return ffi.string(c_str);
end

local mt = { __index = msg_literal };

function msg_literal.new(literals)
	local o = {};
	o.list = literals;
	o = setmetatable(o, mt);
	return o;
end

return msg_literal;

