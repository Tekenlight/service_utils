package = "service_utils"
version = "0.1.0-1"

description = {
   summary = "REST service utilities forLua 5.x",
   detailed = [[
      Pure Lua utilities for serrver side REST interfaces
      The utilities are built on top of evpoco platform
   ]],
   license = "MIT",
   homepage = "https://github.com/Tekenlight/service_utils",
}

dependencies = {
   "lua >= 5.1, < 5.5"
}

source = {
   url = "git://github.com/Tekenlight/service_utils",
   tag = "version_0.1",
}

build = {
   type = "builtin",
   modules = {
	   ["HTTP.generic_http_req_processor"] = 'HTTP/generic_http_req_processor.lua',

	   ["REST.controller"] = 'REST/controller.lua',

	   ["SMTP.dialog_socket"] = 'SMTP/dialog_socket.lua',
	   ["SMTP.email_client"] = 'SMTP/email_client.lua',
	   ["SMTP.mail_message"] = 'SMTP/mail_message.lua',
	   ["SMTP.smtp_client"] = 'SMTP/smtp_client.lua',

	   ["org.evpoco.user_name_type"] = 'org/evpoco/user_name_type.lua',
	   ["org.evpoco.recipient_type_type"] = 'org/evpoco/recipient_type_type.lua',
	   ["org.evpoco.recipient_dtls_type"] = 'org/evpoco/recipient_dtls_type.lua',
	   ["org.evpoco.email_message_type"] = 'org/evpoco/email_message_type.lua',
	   ["org.evpoco.email_message"] = 'org/evpoco/email_message.lua',
	   ["org.evpoco.email_id_type"] = 'org/evpoco/email_id_type.lua',
	   ["org.evpoco.attachment_dtls_type"] = 'org/evpoco/attachment_dtls_type.lua',

	   ["common.file_interface"] = 'common/file_interface.lua',
	   ["common.msg_literal"] = 'common/msg_literal.lua',
	   ["common.password_generator"] = 'common/password_generator.lua',
	   ["common.user_context"] = 'common/user_context.lua',

	   ["db.db_params"] = 'db/db_params.lua',
	   ["db.ev_postgres"] = 'db/ev_postgres.lua',
	   ["db.ev_types"] = 'db/ev_types.lua',
	   ["db.rdbms_interface"] = 'db/rdbms_interface.lua',

   }
}

