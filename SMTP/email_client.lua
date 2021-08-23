local ffi = require('ffi');
local schema_processor = require("schema_processor");
local error_handler = require("lua_schema.error_handler");
local platform = require('platform');

local email_client = {};

local email_services = {
	gmail_tls = { uri = 'smtp.gmail.com', port = '587' }
};

local init = function(self, email_service, user_id, password)
	local smtp_c_f = require('service_utils.SMTP.smtp_client');
	local status, smtp_c = pcall(smtp_c_f.new, email_services[email_service].uri, email_services[email_service].port);
	if (not status) then
		error_handler.raise_error(-1, smtp_c, debug.getinfo(1));
	end

	local status, msg = pcall(smtp_c.login, smtp_c, 'AUTH_LOGIN', user_id, password);
	if (not status) then
		error_handler.raise_error(-1, 'login failed:'..msg, debug.getinfo(1));
		return false, nil;
	end
	return true, smtp_c;
end

local close = function(smtp_c)
	smtp_c:close();
end

email_client.sendmail = function(self, email_message)
	local msg_handler = schema_processor:get_message_handler('email_message', 'http://evpoco.org');
	if (not msg_handler:is_valid(email_message)) then
		return false;
	end

	local status , smtp_c = init(email_client, 'gmail_tls', email_message.from, email_message.password);
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

	for i,v in ipairs(email_message.attachments) do
		mmf.add_attachment(mm, ffi.getptr(v.data.value), tonumber(v.data.size), v.name, v.content_type);
	end

	local status, ret, msg = pcall(smtp_c.send_message, smtp_c, mm);
	if (not status) then
		error_handler.raise_error(-1, ret, debug.getinfo(1));
		return false;
	end
	close(smtp_c);

	return true;
end


return email_client;

