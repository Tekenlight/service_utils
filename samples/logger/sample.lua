local log = require('evlualogger');

local some_func = function ()
    log:debug("try");
    local context = { user_id = 123, ip_address = "192.168.1.1", uuid = require('service_utils.common.utils').uuid() }
    log:set_context(context, "user_id", "ip_address")
    log:debug("DEBUG")
    log:info("INFO")
    log:warn("WARN")
    log:error("ERROR")
    log:fatal("FATAL")

    context = { user_id = 1234, ip_address = "192.168.1.2", uuid = require('service_utils.common.utils').uuid() }
    log:set_context(context, "user_id", "ip_address")
    log:debug("DEBUG")
    log:info("INFO")
    log:warn("WARN")
    log:error("ERROR")
    log:fatal("FATAL")
end

some_func()

log:debug("try");
local context = { user_id = 123, ip_address = "192.168.2.1", uuid = require('service_utils.common.utils').uuid() }
log:set_context(context, "user_id", "ip_address")
log:debug("DEBUG")
log:info("INFO")
log:warn("WARN")
log:error("ERROR")
log:fatal("FATAL")

context = { user_id = 1234, ip_address = "192.168.2.2", uuid = require('service_utils.common.utils').uuid() }
log:set_context(context, "user_id", "ip_address")
log:debug("DEBUG")
log:info("INFO")
log:warn("WARN")
log:error("ERROR")
log:fatal("FATAL")