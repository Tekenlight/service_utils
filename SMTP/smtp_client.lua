local sock_factory = require('service_utils.SMTP.dialog_socket');
local utsname = require('posix.sys.utsname');
local platform = require('platform');
local nu = require('lua_schema.number_utils');

local function status_div(status)
	local q = status / 100;
	q = nu.round(q, 1);
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
		return ret;
	end
	if (is_permanent_negative(ret)) then
		ret, msg = session:send_command('HELO', node_name);
	end
	if (not is_positive_completion(ret)) then
		msg = 'Login failed:'..ret..':'..msg;;
		error(msg);
	end
	ret, msg = session:send_command('STARTTLS');
	session.ds:start_tls();

	return;
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
	init(nc);
	return nc;
end

return  smtp_client_session_factory;
