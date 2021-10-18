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
	   ["service_utils.HTTP.generic_http_req_processor"] = 'HTTP/generic_http_req_processor.lua',

	   ["service_utils.REST.controller"] = 'REST/controller.lua',

	   ["service_utils.SMTP.dialog_socket"] = 'SMTP/dialog_socket.lua',
	   ["service_utils.SMTP.email_client"] = 'SMTP/email_client.lua',
	   ["service_utils.SMTP.mail_message"] = 'SMTP/mail_message.lua',
	   ["service_utils.SMTP.smtp_client"] = 'SMTP/smtp_client.lua',

	   ["org.evpoco.user_name_type"] = 'org/evpoco/user_name_type.lua',
	   ["org.evpoco.recipient_type_type"] = 'org/evpoco/recipient_type_type.lua',
	   ["org.evpoco.recipient_dtls_type"] = 'org/evpoco/recipient_dtls_type.lua',
	   ["org.evpoco.email_message_type"] = 'org/evpoco/email_message_type.lua',
	   ["org.evpoco.email_message"] = 'org/evpoco/email_message.lua',
	   ["org.evpoco.email_id_type"] = 'org/evpoco/email_id_type.lua',
	   ["org.evpoco.attachment_dtls_type"] = 'org/evpoco/attachment_dtls_type.lua',

	   ["service_utils.common.file_interface"] = 'common/file_interface.lua',
	   ["service_utils.common.msg_literal"] = 'common/msg_literal.lua',
	   ["service_utils.common.password_generator"] = 'common/password_generator.lua',
	   ["service_utils.common.user_context"] = 'common/user_context.lua',

	   ["service_utils.db.db_params"] = 'db/db_params.lua',
	   ["service_utils.db.ev_postgres"] = 'db/ev_postgres.lua',
	   ["service_utils.db.ev_types"] = 'db/ev_types.lua',
	   ["service_utils.db.rdbms_interface"] = 'db/rdbms_interface.lua',

   }
}

