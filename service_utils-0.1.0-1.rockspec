package = "service_utils"
version = "0.1.0-1"

description = {
   summary = "REST service utilities forLua 5.x",
   detailed = [[
      Pure Lua utilities for serrver side REST interfaces
      The utilities are built on top of evpoco platform
   ]],
   license = "MIT",
   homepage = "git+https://github.com/Tekenlight/service_utils",
}

dependencies = {
   "lua > 5.2, < 5.5",
   "lua-cjson",
   "penlight",
   "luaposix",
   "lua-uri",
   "luafilesystem",
   "markdown",
   "ldoc"
}

source = {
   url = "git+https://github.com/Tekenlight/service_utils",
   --tag = "version_0.1",
}

build = {
   type = "builtin",
   modules = {
		["service_utils.HTTP.generic_http_req_processor"] = 'HTTP/generic_http_req_processor.lua',

		["org.tekenlight.evpoco.idl_spec.host_config_rec"] = 'org/tekenlight/evpoco/idl_spec/host_config_rec.lua',
		["org.tekenlight.evpoco.idl_spec.host_config_rec_type"] = 'org/tekenlight/evpoco/idl_spec/host_config_rec_type.lua',
		["service_utils.REST.controller"] = 'REST/controller.lua',
		["service_utils.REST.client"] = 'REST/client.lua',
		["service_utils.REST.service_client"] = 'REST/service_client.lua',
		["service_utils.REST.external_service_client"] = 'REST/external_service_client.lua',
		["service_utils.REST.host_utils"] = 'REST/host_utils.lua',
		["service_utils.REST.context_harness"] = 'REST/context_harness.lua',
		["idl_gen"] = 'REST/idl_gen.lua',

		['service_utils.WS.web_socket'] = 'WS/web_socket.lua',
		['service_utils.WS.ws_util'] = 'WS/ws_util.lua',
		['service_utils.WS.ws_const'] = 'WS/ws_const.lua',

		["service_utils.jwt.luajwt"] = 'jwt/luajwt.lua',

		["service_utils.literals.literals"] = 'literals/literals.lua',

		["service_utils.SMTP.dialog_socket"] = 'SMTP/dialog_socket.lua',
		["service_utils.SMTP.email_client"] = 'SMTP/email_client.lua',
		["service_utils.SMTP.mail_message"] = 'SMTP/mail_message.lua',
		["service_utils.SMTP.smtp_client"] = 'SMTP/smtp_client.lua',

		["service_utils.crypto.crypto_utils"] = 'crypto/crypto_utils.lua',

		["org.tekenlight.evpoco.user_name_type"] = 'org/tekenlight/evpoco/user_name_type.lua',
		["org.tekenlight.evpoco.recipient_type_type"] = 'org/tekenlight/evpoco/recipient_type_type.lua',
		["org.tekenlight.evpoco.recipient_dtls_type"] = 'org/tekenlight/evpoco/recipient_dtls_type.lua',
		["org.tekenlight.evpoco.email_message_type"] = 'org/tekenlight/evpoco/email_message_type.lua',
		["org.tekenlight.evpoco.email_message"] = 'org/tekenlight/evpoco/email_message.lua',
		["org.tekenlight.evpoco.email_id_type"] = 'org/tekenlight/evpoco/email_id_type.lua',
		["org.tekenlight.evpoco.attachment_dtls_type"] = 'org/tekenlight/evpoco/attachment_dtls_type.lua',

		['org.tekenlight.evpoco.message_rules.app_info'] = 'org/tekenlight/evpoco/message_rules/app_info.lua',
		['org.tekenlight.evpoco.message_rules.mappings_type'] = 'org/tekenlight/evpoco/message_rules/mappings_type.lua',
		['org.tekenlight.evpoco.message_rules.rule_type'] = 'org/tekenlight/evpoco/message_rules/rule_type.lua',
		['org.tekenlight.evpoco.message_rules.rule_type_type'] = 'org/tekenlight/evpoco/message_rules/rule_type_type.lua',
		['org.tekenlight.evpoco.message_rules.rule_set_type'] = 'org/tekenlight/evpoco/message_rules/rule_set_type.lua',
		['org.tekenlight.evpoco.message_rules.validation_type'] = 'org/tekenlight/evpoco/message_rules/validation_type.lua',

		['org.tekenlight.evpoco.idl_spec.output_dtls_type'] = 'org/tekenlight/evpoco/idl_spec/output_dtls_type.lua',
		['org.tekenlight.evpoco.idl_spec.http_method_type'] = 'org/tekenlight/evpoco/idl_spec/http_method_type.lua',
		['org.tekenlight.evpoco.idl_spec.method_type'] = 'org/tekenlight/evpoco/idl_spec/method_type.lua',
		['org.tekenlight.evpoco.idl_spec.interface_type'] = 'org/tekenlight/evpoco/idl_spec/interface_type.lua',
		['org.tekenlight.evpoco.idl_spec.interface'] = 'org/tekenlight/evpoco/idl_spec/interface.lua',
		['org.tekenlight.evpoco.idl_spec.input_source_type'] = 'org/tekenlight/evpoco/idl_spec/input_source_type.lua',
		['org.tekenlight.evpoco.idl_spec.input_dtls_type'] = 'org/tekenlight/evpoco/idl_spec/input_dtls_type.lua',
		['org.tekenlight.evpoco.idl_spec.error_response_type'] = 'org/tekenlight/evpoco/idl_spec/error_response_type.lua',
		['org.tekenlight.evpoco.idl_spec.error_response'] = 'org/tekenlight/evpoco/idl_spec/error_response.lua',
		['org.tekenlight.evpoco.idl_spec.host_ipv4_address_type'] = 'org/tekenlight/evpoco/idl_spec/host_ipv4_address_type.lua',
		['org.tekenlight.evpoco.idl_spec.host_url_type'] = 'org/tekenlight/evpoco/idl_spec/host_url_type.lua',
		['org.tekenlight.evpoco.idl_spec.host_config_rec_type'] = 'org/tekenlight/evpoco/idl_spec/host_config_rec_type.lua',
		['org.tekenlight.evpoco.idl_spec.host_config_rec'] = 'org/tekenlight/evpoco/idl_spec/host_config_rec.lua',

		['org.tekenlight.evpoco.tbl_spec.tbldef_type'] = 'org/tekenlight/evpoco/tbl_spec/tbldef_type.lua',
		['org.tekenlight.evpoco.tbl_spec.tbldef'] = 'org/tekenlight/evpoco/tbl_spec/tbldef.lua',
		['org.tekenlight.evpoco.tbl_spec.indexes_type'] = 'org/tekenlight/evpoco/tbl_spec/indexes_type.lua',
		['org.tekenlight.evpoco.tbl_spec.index_type'] = 'org/tekenlight/evpoco/tbl_spec/index_type.lua',
		['org.tekenlight.evpoco.tbl_spec.index_column_type'] = 'org/tekenlight/evpoco/tbl_spec/index_column_type.lua',
		['org.tekenlight.evpoco.tbl_spec.columns_type'] = 'org/tekenlight/evpoco/tbl_spec/columns_type.lua',
		['org.tekenlight.evpoco.tbl_spec.column_type'] = 'org/tekenlight/evpoco/tbl_spec/column_type.lua',

		["service_utils.common.msg_literal"] = 'common/msg_literal.lua',
		["service_utils.common.password_generator"] = 'common/password_generator.lua',
		["service_utils.common.user_context"] = 'common/user_context.lua',
		["service_utils.common.utils"] = 'common/utils.lua',
		["service_utils.common.pool_repos"] = 'common/pool_repos.lua',
		["service_utils.common.constants"] = 'common/constants.lua',
		["service_utils.common.primitive_serde"] = 'common/primitive_serde.lua',
		["service_utils.common.compression"] = 'common/compression.lua',

		["service_utils.db.client_params"] = 'db/client_params.lua',
		["service_utils.db.ev_database"] = 'db/ev_database.lua',
		["service_utils.db.ev_postgres"] = 'db/ev_postgres.lua',
		["service_utils.db.ev_redis"] = 'db/ev_redis.lua',
		["service_utils.db.ev_types"] = 'db/ev_types.lua',
		["service_utils.db.rdbms_interface"] = 'db/rdbms_interface.lua',

		["service_utils.validation.validate_map"] = 'schemarules/validate_map.lua',

		["generate_appinfo"] = 'schemarules/generate_appinfo.lua',
		["generate_val"] = 'schemarules/generate_val.lua',

		["tblgen"] = 'orm/tblgen.lua',
		["genmake"] = 'package/genmake.lua',
		["generator"] = 'package/generator.lua',

		["service_utils.common.logger"] = 'logging/logger.lua',

		["service_utils.orm.transaction"] = 'orm/transaction.lua',
		["service_utils.orm.tao_factory"] = 'orm/tao_factory.lua',
		["service_utils.orm.mapping_util"] = 'orm/mapping_util.lua',
		["service_utils.orm.single_crud_factory"] = 'orm/single_crud_factory.lua',

		["service_utils.unitt.harness"] = 'unitt/harness.lua',

   },
   install = {
		bin = {
			gappinfo = 'schemarules/gappinfo',
			gval = 'schemarules/gval',
			gidl = 'REST/gidl',
			gentbl = 'orm/gentbl',
			build = 'package/build',
			deploy = 'package/deploy',
			grockspec = 'package/grockspec';
		}
	}
}

