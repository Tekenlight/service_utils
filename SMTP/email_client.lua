local ffi = require('ffi');
local schema_processor = require("schema_processor");
local error_handler = require("lua_schema.error_handler");
local platform = require('platform');

local email_client = {};

local email_services = {
	gmail_tls = { uri = 'smtp.gmail.com', port = '587' }
};

email_client.init = function(self, email_service, user_id, password)
	local smtp_c_f = require('service_utils.SMTP.smtp_client');
	local smtp_c = smtp_c_f.new(email_services[email_service].uri, email_services[email_service].port);

	if (not smtp_c:login('AUTH_LOGIN', user_id, password)) then
		error_handler.raise_error(-1, 'login failed', debug.getinfo(1));
		return false, nil;
	end
	return true, smtp_c;
end

email_client.sendmail = function(self, email_message)
	local msg_handler = schema_processor:get_message_handler('email_message', 'http://evpoco.org');
	if (not msg_handler:is_valid(email_message)) then
		return false;
	end

	local status , smtp_c = self:init('gmail_tls', email_message.from, email_message.password);
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

	local ret, msg = smtp_c:send_message(mm);
	smtp_c:close();

	return true;
end


return email_client;

