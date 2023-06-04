local ffi = require('ffi');
local schema_processor = require("schema_processor");
local error_handler = require("lua_schema.error_handler");
local smtp_c_f = require('service_utils.SMTP.smtp_client');
local platform = require('platform');
local evclient = (require('service_utils.common.utils')).load_library('libevclient');
local properties_funcs = platform.properties_funcs();
local enablesmtpclientpool = properties_funcs.get_bool_property("service_utils.SMTP.email_client.enablesmtpclientpool");
if (enablesmtpclientpool == nil) then
	enablesmtpclientpool = false;
end


local email_client = {};

local conn_type = 'socket_connection_pool';

local email_services = {
	gmail_tls = { uri = 'smtp.gmail.com', port = '587' }
};

local make_connection = function(self, email_service, user_id, password, name)
	local status, smtp_c = pcall(smtp_c_f.new, conn_type, email_services[email_service].uri, email_services[email_service].port, name);
	if (not status) then
		error_handler.raise_error(500, smtp_c);
		error(smtp_c);
	end

	local status, msg = pcall(smtp_c.login, smtp_c, 'AUTH_LOGIN', user_id, password);
	if (not status) then
		error_handler.raise_error(500, 'login failed:'..msg);
		return false, nil;
	end

	if (enablesmtpclientpool) then
		smtp_c:set_socket_to_be_cached(true);
	end

	smtp_c:set_user_id_in_ds(user_id);

	return true, smtp_c;
end
local init = function(self, email_service, user_id, password, name)

	local smtp_c = nil;
	local host = email_services[email_service].uri ..':'.. email_services[email_service].port;
	local status, ss_ptr = pcall(evclient.get_from_pool, conn_type, host, user_id);
	if (not status) then
		error_handler.raise_error(500, ss_ptr);
		return false, nil;
	end
	
	local ss = nil;
	local from_pool = false;

	if (nil ~= ss_ptr) then
		ss = ss_ptr;
		--status, ss = pcall(platform.use_pooled_connection, ss_ptr);
		--if (not status) then
			--error_handler.raise_error(500, ss);
			--return false, nil;
		--end
		status, smtp_c = pcall(smtp_c_f.new_from_cached_ss, ss, conn_type, email_services[email_service].uri, email_services[email_service].port, user_id, name);
		if (not status) then
			error_handler.raise_error(500, smtp_c);
			return false, nil;
		end
		from_pool = true;
	else
		local status = nil;
		if (smtp_c == nil) then
			status, smtp_c = make_connection(self, email_service, user_id, password, name);
			if (not status) then
				return false, nil;
			end
		end
		from_pool = false;
	end

	return true, smtp_c, from_pool;
end

local close = function(smtp_c)
	if (not enablesmtpclientpool) then
		smtp_c:close();
	end
end

email_client.sendmail = function(self, email_service, email_message)
	local msg_handler = schema_processor:get_message_handler('email_message', 'http://evpoco.tekenlight.org');
	if (msg_handler == nil) then
		error_handler.raise_error(500, "Could not locate message schema handler");
		return false;
	end

	local stat, status = pcall(msg_handler.is_valid, msg_handler, email_message);
	if (not stat) then
		error_handler.raise_error(500, status);
		return false;
	end
	if (not status) then
		return false;
	end

	local status , smtp_c, conn_from_pool = init(email_client, email_service, email_message.from, email_message.password, email_message.name);
	if (not status) then
		return false;
	end

	local mmf = platform.mail_message_funcs();
	local mm = mmf.new();
	local sender = nil;
	if (email_message.sender_name ~= nil) then
		sender = email_message.sender_name .. '<'.. email_message.from .. '>';
	else
		sender = email_message.from;
	end
	mmf.set_sender(mm, sender);
	for i,v in ipairs(email_message.recipients) do
		if (v.real_name == nil) then
			mmf.add_recipient(mm, v.address, v.recipient_type);
		else
			mmf.add_recipient(mm, v.address, v.recipient_type, v.real_name);
		end
	end
	mmf.set_subject(mm, email_message.subject);
	mmf.add_content(mm, email_message.message_body);

	if (email_message.attachments ~= nil) then
		for i,v in ipairs(email_message.attachments) do
			mmf.add_attachment(mm, ffi.getptr(v.data.value), tonumber(v.data.size), v.name, v.content_type);
		end
	end

	--local status, ret, msg = pcall(smtp_c.send_message, smtp_c, mm);
	local status, ret, msg = pcall(smtp_c.pipeline_send_message, smtp_c, mm);
	if (not status) then
		if (conn_from_pool) then
			if (smtp_c:connection_is_bad()) then
				smtp_c:release_connection();
				smtp_c = nil;
				status, smtp_c = make_connection(self, email_service, email_message.from, email_message.password, email_message.name);
				if (not status) then
					return false;
				end
			end
			status, ret = pcall(smtp_c.pipeline_send_message, smtp_c, mm);
			if (not status) then
				smtp_c:release_connection();
				return false;
			end
		else
			smtp_c:release_connection();
			return false;
		end
	end

	smtp_c:release_connection();
	return true;
end


return email_client;

