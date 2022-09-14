local constants = rawget(_G, "constants");
if (constants == nil) then
	rawset(_G, "constants", {});
	constants = rawget(_G, "constants");

	constants.RECV_TIMEOUT_EXTERNAL_SOCKETS = 40;
	constants.SEND_TIMEOUT_EXTERNAL_SOCKETS = 40;

	constants.RECV_TIMEOUT_SMTP_SOCKETS = 20;
	constants.SEND_TIMEOUT_SMTP_SOCKETS = 20;

	constants.RECV_TIMEOUT_INTERNAL_SOCKETS = 20;
	constants.SEND_TIMEOUT_INTERNAL_SOCKETS = 20;
end

return constants;
