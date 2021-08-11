local platform = require('platform');
local mail_funcs = platform.mail_message_funcs();
local mail_message = {};

mail_message.set_sender = function(self, s)
	mail_funcs.set_sender(self._bin_message, s);
end

mail_message.add_recipient = function(self, s)
	mail_funcs.add_recipient(self._bin_message, s);
end

mail_message.set_subject = function(self, s)
	mail_funcs.set_subject(self._bin_message, s);
end

mail_message.add_content = function(self, s)
	mail_funcs.add_content(self._bin_message, s);
end

mail_message.add_attachment = function(self, val, size, attachment_name, content_type)
	mail_funcs.add_attachment(self._bin_message, val, size, attachment_name, content_type);
end

local mt = { __index = mail_message };
local mail_message_factory = {};

mail_message_factory.new = function(host, port)
	local mm = {};
	mm = setmetatable(mm, mt);
	mm._bin_message = mail_funcs.new();
	return mm;
end

return  mail_message_factory;



