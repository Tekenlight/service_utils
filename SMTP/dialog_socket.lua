local ffi = require('ffi');
local platform = require('platform');
local netssl = (require('service_utils.common.utils')).load_library('libevlnetssl');
local evclient = (require('service_utils.common.utils')).load_library('libevclient');
local error_handler = require("lua_schema.error_handler");
local constants = require('service_utils.common.constants');


ffi.cdef[[
char * strcpy(char * dst, const char * src);
]]

local dialog_socket = {};

dialog_socket.send_bytes = function(self)
	local buffer_element = self.output_buffer;
	local status, ret = pcall(platform.send_data_on_socket, self.ss,
			ffi.getptr(buffer_element.buf), buffer_element.size, constants.SEND_TIMEOUT_SMTP_SOCKETS);
	if (not status) then
		error_handler.raise_error(-1, ret, debug.getinfo(1));
		self.socket_in_error = true;
		error(ret);
	end
	return ret;
end

dialog_socket.receive_data = function(self)
	local buffer_element = self.input_buffer;
	local status, ret = pcall(platform.recv_data_from_socket, self.ss,
						ffi.getptr(buffer_element.buf), 1024, constants.RECV_TIMEOUT_SMTP_SOCKETS);
	if (not status) then
		print(debug.getinfo(1).source, debug.getinfo(1).currentline);
		platform.debug_ss_ptr(self.ss);
		print(debug.getinfo(1).source, debug.getinfo(1).currentline);
		error_handler.raise_error(-1, ret, debug.getinfo(1));
		self.socket_in_error = true;
		error(ret);
	end
	buffer_element.size = ret;
	return ret;
end

dialog_socket.peek = function(self)
	local buffer_element = self.input_buffer;
	if (buffer_element.index >= buffer_element.size) then
		buffer_element.size = 0;
		buffer_element.index = 0;
		self:receive_data();
	end
	local ch = buffer_element.buf[buffer_element.index];
	return string.char(ch);
end

dialog_socket.get_ch = function(self)
	local buffer_element = self.input_buffer;
	if (buffer_element.index >= buffer_element.size) then
		buffer_element.size = 0;
		buffer_element.index = 0;
		self:receive_data();
	end
	if (buffer_element.size == 0) then
		return nil;
	end
	local ch = buffer_element.buf[buffer_element.index]
	buffer_element.index = buffer_element.index+1;
	return string.char(ch);
end

dialog_socket.receive_line = function(self, i_msg, i_limit)
	local line = i_msg;
	local l_line = '';
	local limit = i_limit;
	if (line == nil) then line = ''; end
	if (limit == nil) then limit = 4096; end

	local ch = self:get_ch();
	if (ch ~= nil) then l_line = ''; end
	while (ch ~= nil and ch ~= '\r' and ch ~='\n') do
		-- Is there a limit to line_length
		l_line = l_line .. ch;
		ch = self:get_ch();
	end
	if (ch == '\r' and self:peek() == '\n') then
		self:get_ch();
	elseif (ch == nil) then
		return nil;
	end
	line = line .. l_line
	return line;
end

local stringx = require('pl.stringx');

dialog_socket.receive_status_line = function(self, i_msg, limit)
	local ret = 0;
	local line = i_msg;
	local ch = self:get_ch();
	if (nil ~= ch) then
		if (line == nil) then line = ''; end
		line = line .. ch;
	end
	local n = 0;
	while (stringx.isdigit(ch) and n < 3) do
		ret = ret * 10;
		ret = ret + tonumber(ch);
		n = n + 1;
		ch = self:get_ch();
		if (ch ~= nil) then
			line = line .. ch;
		end
	end
	if (n == 3) then
		if (ch == '-') then
			ret = -1 * ret;
		end
	else
		ret = 0;
	end
	if (ch ~= nil) then
		line = self:receive_line(line, limit);
	end
	return ret, line;
end

dialog_socket.connection_is_bad = function(self)
	return self.socket_in_error
end

dialog_socket.receive_status_message = function(self)
	local ret = 0;
	local msg = '';
	local i = 0;

	ret, msg = self:receive_status_line(msg, 4096);
	if (ret < 0) then
		while (ret <= 0) do
			msg = msg..'\n';
			ret, msg = self:receive_status_line(msg, 4096);
		end
	end

	return ret, msg;
end

dialog_socket.send_string = function(self, string_data)
	local size = string.len(string_data);
	if (size > 1024) then
		error_handler.raise_error(-1, "Cannot send messages > 1024 bytes", debug.getinfo(1));
		return nil;
	end
	local buffer_element = self.output_buffer;
	ffi.C.strcpy(buffer_element.buf, string_data);
	buffer_element.size = size;
	buffer_element.index = 0;
	return self:send_bytes();
end

dialog_socket.send_message = function(self, str, arg1, arg2)
	if (str == nil or type(str) ~= 'string') then
		error_handler.raise_error(-1, "Invalid inputs", debug.getinfo(1));
		error("Invalid inputs");
	end
	if ((arg1 ~= nil) and (type(arg1) ~= 'string')) then
		error_handler.raise_error(-1, "Invalid inputs", debug.getinfo(1));
		error("Invalid inputs");
	end
	if ((arg2 ~= nil) and (type(arg2) ~= 'string')) then
		error_handler.raise_error(-1, "Invalid inputs", debug.getinfo(1));
		error("Invalid inputs");
	end
	local string_data = str
	if (arg1 ~= nil) then string_data = string_data ..' '..arg1; end
	if (arg2 ~= nil) then string_data = string_data ..' '..arg2; end
	string_data = string_data .. '\r\n';

	return self:send_string(string_data);
end

dialog_socket.start_tls = function(self)
	netssl.connect_TLS(self.ss);
	return ;
end

dialog_socket.transport_cms = function(self, cms)
	local ret = platform.send_cms_on_socket(self.ss, cms, constants.SEND_TIMEOUT_SMTP_SOCKETS);
	if (ret <= 0) then
		return false;
	else
		return true;
	end
end

dialog_socket.close = function(self)
	platform.close_tcp_connection(self.ss);
end

dialog_socket.set_name = function(self, name)
	self.name = name;
end

dialog_socket.set_socket_to_be_cached = function(self, flag)
	if (flag == nil or type(flag) ~= 'boolean') then
		error_handler.raise_error(-1, "dialog_socket.set_socket_to_be_cached : invalid inputs", debug.getinfo(1));
		error("dialog_socket.set_socket_to_be_cached : invalid inputs");
	end
	self.to_be_cached = flag;
	--platform.set_socket_managed(self.ss, flag);
end

dialog_socket.cleanup = function (self)
	if (self.to_be_cached and not self.socket_in_error) then
		local h = self.host..':'..self.port
		evclient.add_to_pool(self.conn_type, h, self.name, self.ss);
	else
		self:close();
		--platform.cleanup_stream_socket(self.ss);
	end
end

local ds_gc = function()
end

local mt = { __index = dialog_socket,  __gc = ds_gc };
--local mt = { __index = dialog_socket };
local dialog_socket_factory = {};

dialog_socket_factory.new = function(ss, conn_type, host, port)
	local ds = {};
	ds = setmetatable(ds, mt);
	ds.ss = ss;
	ds.host = host;
	ds.port = port;
	ds.conn_type = conn_type;
	ds.input_buffer = {};
	ds.input_buffer.size = 0;
	ds.input_buffer.index = 0;
	ds.input_buffer.buf = ffi.new("unsigned char[?]", 1024);
	ds.output_buffer = {};
	ds.output_buffer.size = 0;
	ds.output_buffer.index = 0;
	ds.output_buffer.buf = ffi.new("unsigned char[?]", 1024);
	ds.socket_in_error = false;
	ds.to_be_cached = false;
	return ds;
end

return  dialog_socket_factory;

