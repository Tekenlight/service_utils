local letters = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"}
local LETTERS = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
local numbers = {'1','2','3','4','5','6','7','8','9','0'}
local symbols = {"!","@","#","$","%","^","&","*","/"}
local ffi = require('ffi');
ffi.cdef[[
int getentropy(void *buf, size_t buflen);
void * malloc(size_t size);
]]

local function get_ran_num(modulo_base)
	local cp = ffi.new("unsigned char [?]", 1);
	ffi.C.getentropy(cp, 1);
	return tonumber(cp[0] % modulo_base);
end

local pwd_gen = {};

local pwd_chars = { letters, LETTERS, numbers, symbols };

function pwd_gen.generate_pw()
	local pwd = '';
	local i = 0;
	local pool;
	local r1, r2;

	while (i < 20) do
		i = i + 1;
		r1 = get_ran_num((#pwd_chars))
		r1 = r1 + 1;
		pool = pwd_chars[r1]
		r2 = get_ran_num((#pool));
		r2 = r2 + 1;
		pwd = pwd..pool[r2];
	end

	return pwd;
end

return pwd_gen;
