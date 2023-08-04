local logger = {};

logger.init = function(self, context, ...)
    local properties_funcs = platform.properties_funcs();
    local fileLocation = properties_funcs.get_string_property("logging.file_location") or os.getenv("EVLUA_PATH");
    local loggingLevel = properties_funcs.get_string_property("logging.level") or "OFF";
    local fileName = properties_funcs.get_string_property("logging.file_name") or "evlua";
    local logToConsole = properties_funcs.get_bool_property("logging.log_to_console") or false;
    local logToFile = properties_funcs.get_bool_property("logging.log_to_file") or false;

    context = context or {};
    local contextFieldToBeLogged = { ... };

    local log = require('logging').new(function(self, level, message)
        local info = debug.getinfo(3);

        local logInfo = {
            date = os.date("%Y-%m-%d %H:%M:%S"),
            level = level,
            source = string.format("%s:%d:%s", info.short_src, info.currentline, info.name or "main"),
            message = message,
            uuid = context.uuid or require('service_utils.common.utils').uuid(),
        }

        for _, value in ipairs(contextFieldToBeLogged) do
            logInfo[value] = context[value];
        end

        local formattedMessage = require "cjson".encode(logInfo)

        if logToConsole then print(formattedMessage) end
        if logToFile then
            local file = io.open(fileLocation .. "/" .. fileName .. ".log", "a")
            if file then
                file:write(formattedMessage .. "\n")
                file:close()
            end
        end
    end)

    log:setLevel(loggingLevel)

    self.log = log

    return self;
end

logger.set_context = function (self, context , ...)
    assert(context == nil or type(context) == "table", "context must be nil or a table");
    logger:init(context, ...);
end

logger.debug = function (self, message)
    self.log:debug(message);
end

logger.info = function (self, message)
    self.log:info(message);
end

logger.warn = function (self, message)
    self.log:warn(message);
end

logger.error = function (self, message)
    self.log:error(message);
end

logger.fatal = function (self, message)
    self.log:fatal(message);
end

return logger:init();
