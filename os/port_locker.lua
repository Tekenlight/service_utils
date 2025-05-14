local os = require('service_utils.os');
local fcntl = require('posix.fcntl');
local sys_stat = require('posix.sys.stat');
local ffi = require('ffi');

ffi.cdef[[
int close(int fd);
]];

local port_locker = {}

local lock_prefix = "/tmp/chrome-port-"
local lock_suffix = ".lock"

--- Try to create a lock file for the given port.
-- Returns true if lock succeeded, false otherwise.
local try_create_lock_file = function(lock_file)
    local  o_flags = fcntl.O_CREAT | fcntl.O_EXCL | fcntl.O_WRONLY;
    local stat, fd = pcall(os.open_file, lock_file, o_flags);
    if (not stat or fd == -1 or fd == nil) then
        return false;
    end
    ffi.C.close(fd);

    local file, err = io.open(lock_file, "w")  -- 'x' = fail if file exists
    if file then
        file:write(tostring(os.time()))  -- optional: write timestamp for debug
        file:close()
        return true
    else
        return false
    end
end

--- Reserve a port by locking it via a file
-- Tries ports in the given range and returns the first free one
-- Raises error if none available
port_locker.reserve_port = function(start_port, end_port)
    start_port = start_port or 30000
    end_port = end_port or 31000

    for port = start_port, end_port do
        local lock_file = lock_prefix .. port .. lock_suffix
        if try_create_lock_file(lock_file) then
            return port
        end
    end

    error("No free port available in range " .. start_port .. "–" .. end_port)
end

--- Release a previously reserved port
port_locker.release_port = function(port)
    local lock_file = lock_prefix .. port .. lock_suffix
    os.remove(lock_file)
end

return port_locker

