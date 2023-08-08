local logger = {};

local function rollLogFile(maxBackupFiles, logFileName)
    local fileNum = maxBackupFiles - 1
    while fileNum > 0 do
        local currentFile = string.format("%s.%d", logFileName, fileNum)
        local nextFile = string.format("%s.%d", logFileName, fileNum + 1)
        os.rename(currentFile, nextFile)
        fileNum = fileNum - 1
    end
    os.rename(logFileName, logFileName .. ".1")
end

logger.init = function(self, context, ...)
    local properties_funcs = platform.properties_funcs();
    local fileLocation = properties_funcs.get_string_property("logging.file_location") or os.getenv("EVLUA_PATH");
    local loggingLevel = properties_funcs.get_string_property("logging.level") or "OFF";
    local fileName = properties_funcs.get_string_property("logging.file_name") or "evlua";
    local logToConsole = properties_funcs.get_bool_property("logging.log_to_console") or false;
    local logToFile = properties_funcs.get_bool_property("logging.log_to_file") or false;
    local maxBackupFile = properties_funcs.get_int_property("logging.max_backup_file") or 1;
    local maxFileSize = (properties_funcs.get_int_property("logging.max_file_size") or 1) * 1024;

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

            -- Check if the file size exceeds the maximum
            local filesize = io.open(fileLocation .. "/" .. fileName .. ".log", "r"):seek("end")
            if filesize >= maxFileSize then
                rollLogFile(maxBackupFile, fileLocation .. "/" .. fileName .. ".log")
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
