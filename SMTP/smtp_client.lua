local ffi = require('ffi');
local sock_factory = require('service_utils.SMTP.dialog_socket');
local utsname = require('posix.sys.utsname');
local platform = require('platform');
local mmf = platform.mail_message_funcs();
local nu = require('lua_schema.number_utils');
local core_utils = require('lua_schema.core_utils');

ffi.cdef [[
char * strcpy(char * dst, const char * src);
void * malloc(size_t size);
void* pthread_self(void);
int printf(const char * restrict format, ...);
]]

local function status_div(status)
	local q = status / 100;
	q = math.floor(q);
	return q;
end

local function is_positive_completion(status)
	local q = status_div(status);
	return (q == 2);
end

local function is_positive_intermediate(status)
	local q = status_div(status);
	return (q == 3);
end

local function is_transient_negative(status)
	local q = status_div(status);
	return (q == 4);
end

local function is_permanent_negative(status)
	local q = status_div(status);
	return (q == 5);
end

local smtp_client_session = {};

smtp_client_session.login_methods = {
	AUTH_NONE = 'AUTH_NONE',
	AUTH_CRAM_MD5 = 'AUTH_CRAM_MD5',
	AUTH_CRAM_SHA1 = 'AUTH_CRAM_SHA1',
	AUTH_LOGIN = 'AUTH_LOGIN',
	AUTH_PLAIN = 'AUTH_PLAIN',
	AUTH_XOAUTH2 = 'AUTH_XOAUTH2'
};

local function open(session)
	if (not session.is_open) then
		session.is_open = true;
		session.ds:receive_line();
	end
	return;
end

local function init(session)
	local node_name = utsname.uname().nodename;
	open(session);
	local ret, msg = session:send_command('EHLO', node_name);
	if (ret == nil) then
		return false;
	end
	if (is_permanent_negative(ret)) then
		ret, msg = session:send_command('HELO', node_name);
	end
	if (not is_positive_completion(ret)) then
		msg = 'Login failed:'..ret..':'..msg;;
		return false, msg;
	end
	ret, msg = session:send_command('STARTTLS');
	if (not is_positive_completion(ret)) then
		msg = 'TLS could not be initiated';
		return false, msg;
	end
	session.ds:start_tls();

	return true;
end

local function login_using_login(session, user_name, password)
	local ret, response = session:send_command('AUTH LOGIN');
	if (not is_positive_intermediate(ret)) then
		return false, response;
	end
	local resp_msg = string.sub(response, 5);
	local resp_val = core_utils.base64_decode(resp_msg);
	resp_val.value[resp_val.size] = 0;
	local field = ffi.string(resp_val.value);

	local b64_user_name = core_utils.str_base64_encode(user_name);
	local b64_password = core_utils.str_base64_encode(password);
	--[[
	print(debug.getinfo(1).source, debug.getinfo(1).currentline,
		ffi.string(ffi.cast("char*", core_utils.base64_decode(b64_user_name).value)));
	print(debug.getinfo(1).source, debug.getinfo(1).currentline, '[Passord = '..
		ffi.string(ffi.cast("char*", core_utils.base64_decode(b64_password).value)).. ']');
	--]]

	if (field == 'Username:') then
		local ret, response = session:send_command(b64_user_name);
		if (not is_positive_intermediate(ret)) then
			return false, response;
		end

		ret, response = session:send_command(b64_password);
		if (not is_positive_completion(ret)) then
			return false, response;
		end
	else
		local ret, response = session:send_command(b64_password);
		if (not is_positive_completion(ret)) then
			return false, response;
		end

		local ret, response = session:send_command(b64_user_name);
		if (not is_positive_intermediate(ret)) then
			return false, response;
		end
	end

	return true;
end

smtp_client_session.login = function(self, method, user_name, password)
	if (smtp_client_session.login_methods[method] == nil) then
		error('Invalid method');
	end
	--[[ TO BEGIN WITH LET US SUPPORT ONE METHOD ]]
	if (smtp_client_session.login_methods[method] ~= smtp_client_session.login_methods.AUTH_LOGIN) then
		local msg = 'Invalid method';
		return false, msg;
	end
	if (user_name == nil or type(user_name) ~= 'string') then
		local msg = 'Invalid user_name';
		return false, msg;
	end
	if (password == nil or type(password) ~= 'string') then
		local msg = 'Invalid user_name';
		return false, msg;
	end
	if (smtp_client_session.login_methods[method] == smtp_client_session.login_methods.AUTH_LOGIN) then
		if (not login_using_login(self, user_name, password)) then
			return false, 'login method not suported';
		end
	end
	return true;

end

smtp_client_session.send_command = function(self, command, arg1, arg2)
	local ret = self.ds:send_message(command, arg1, arg2);
	local msg = nil;
	if (nil == ret) then
		error("Unable to send message");
	end
	ret, msg = self.ds:receive_status_message();
	return ret, msg;
end

smtp_client_session.send_commands = function(self, mail_message)
	local ret = 0;
	local msg = nil;
	local sender = mmf.get_sender(mail_message);
	if (sender == nil) then
		msg = "sender cannot be nil";
		print(debug.getinfo(1).source, debug.getinfo(1).currentline, msg);
		return false, msg;
	end
	local i, j = string.find(sender, "<.*>");
	local f_sender = nil;
	if (i ~= nil) then
		f_sender = string.sub(sender, i, j);
	else
		f_sender = '<'..sender..'>';
	end
	ret, msg = self:send_command('MAIL FROM:', f_sender);
	if (not is_positive_completion(ret)) then
		print(debug.getinfo(1).source, debug.getinfo(1).currentline, msg);
		return false, msg;
	end
	local recipients = mmf.get_recipients(mail_message);
	if (recipients == nil or type(recipients) ~= 'table' or #recipients == 0) then
		msg = "Atlease one recipient should be there";
		print(debug.getinfo(1).source, debug.getinfo(1).currentline, msg);
		return false, msg;
	end
	for i,v in ipairs(recipients) do
		local command = 'RCPT TO:'..'<'..v.address..'>';
		ret, msg = self:send_command(command);
		if (not is_positive_completion(ret)) then
			print(debug.getinfo(1).source, debug.getinfo(1).currentline, ret, msg);
			return false, msg;
		end
	end
	ret, msg = self:send_command('DATA');
	if (not is_positive_intermediate(ret)) then
		print(debug.getinfo(1).source, debug.getinfo(1).currentline, ret, msg);
		return false, msg;
	end

	return true, nil;
end

smtp_client_session.send_message = function(self, mail_message)
	local ret = 0;
	local msg = nil;
	self:send_commands(mail_message);

	local cms = mmf.serialize_message(mail_message);
	if (not self.ds:transport_cms(cms)) then
		return false, 'Could not send mail message';
	end

	ret, msg = self.ds:receive_status_message();
	if (not is_positive_completion(ret)) then
		return false, msg;
	end

	return true, msg;
end

smtp_client_session.close = function(self)
	local ret = 0;
	local msg = nil;
	if (self.is_open) then
		self:send_command('QUIT');
		self.ds:close();
	end
end

local mt = { __index = smtp_client_session };
local smtp_client_session_factory = {};

smtp_client_session_factory.new = function(host, port)
	local nc = {};
	nc = setmetatable(nc, mt);
	local ss, msg = platform.make_tcp_connection(host, port);
	if (ss == nil) then
		error('Unable to connect to connect to the SMT server '.. host..':'..port);
	end
	nc.ds = sock_factory.new(ss, host, port);
	nc.is_open = false;
	if (not init(nc)) then
		return nil;
	end
	return nc;
end

return  smtp_client_session_factory;
