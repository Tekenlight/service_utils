local ffi = require('ffi');
local cu = require('lua_schema.core_utils');

ffi.cdef[[
int pipe(int pipefd[2]);
int printf(const char *, ...);
int close(int fd);
int dup2(int oldfd, int newfd);
ssize_t read(int fd, void *buf, size_t count);
ssize_t write(int fd, const void *buf, size_t count);
void *memset(void *s, int c, size_t n);
void *realloc(void *ptr, size_t size);
]]

local os = {}

local unistd = require 'posix.unistd';
local stringx = require('pl.stringx');
local syswait = require('posix.sys.wait');
local pe = require('posix.errno');

--[[
This is an implementation similar to glibc system.

The glibc impmentation uses signals SIGCHLD, SIGINT, SIGQUIT to manage the execution, this may interfere
with the multithreaded environment of evlua.
]]
os.system = function(cmd)
    assert(type(cmd) == 'string', 'Invalid input to os.system');

    cmd = stringx.strip(cmd);

    local ret, msg, errno ;
    local pid = unistd.fork()
    if (pid == 0) then
        local msg, errno = unistd.exec('/bin/sh', {[0] = 'sh', '-c', cmd});
        error(msg .. 'errno = ' .. errno);
    elseif (pid > 0) then
        ret, msg, errno = syswait.wait(pid);
    else
        error('Unable to fork error:['..pid..']');
    end

    return ret, msg, errno;
end

os.r_popen = function(cmd, inp_data)
    assert(type(cmd) == 'string', 'Invalid input to os.system');
    assert((inp_data == nil or ffi.istype("hex_data_s_type", inp_data) == true), 'Invalid input to os.r_popen');

    local r_pipefd = ffi.new('int [2]')
    ffi.C.pipe(r_pipefd);

    local w_pipefd;
    if (inp_data ~= nil) then
        w_pipefd = ffi.new('int [2]')
        ffi.C.pipe(w_pipefd);
    end
 
    cmd = stringx.strip(cmd);

    local ret, msg, errno ;
    local pid = unistd.fork()
    if (pid == 0) then
        ffi.C.close(r_pipefd[0]);
        ffi.C.close(1);
        ffi.C.dup2(r_pipefd[1], 1);
        if (inp_data ~= nil) then
            ffi.C.close(w_pipefd[1]);
            ffi.C.close(0);
            ffi.C.dup2(w_pipefd[0], 0);
        end
        ret, msg, errno = unistd.exec('/bin/sh', {[0] = 'sh', '-c', cmd});
        error(msg .. 'errno = ' .. errno);
    elseif (pid > 0) then
        ffi.C.close(r_pipefd[1]);
        if (inp_data ~= nil) then
            ffi.C.close(w_pipefd[0]);
            local ret = ffi.C.write(w_pipefd[1], inp_data.value, inp_data.size);
            if (ret < 0) then
                local msg, n = pe.errno();
                ffi.C.close(w_pipefd[1]);
                error('Error writing to fd '.. msg);
            end
            ffi.C.close(w_pipefd[1]);
        end
        ret, msg, errno = syswait.wait(pid);
    else
        error('Unable to fork error:['..pid..']');
    end

    return ret, r_pipefd[0], msg, errno;
end

os.r_pread = function(fd)
    local c_buf = ffi.cast('char*', ffi.new('char*', ffi.C.NULL));
    local n = ffi.new('ssize_t [2]', 0);
    ffi.C.memset(n, 0, 2);
    local count = 0;
    repeat
        count = count + 1;
        n[1] = n[1] + n[0];
        n[0] = 0;
        local new_size = count * 1024;
        c_buf = ffi.cast('char*', ffi.C.realloc(ffi.getptr(c_buf), new_size+1));
        ffi.C.memset(c_buf+(new_size-1024), 0, 1024+1);
        n[0] = ffi.C.read(fd, ffi.getptr(c_buf+(new_size-1024)), 1024);
        if (tonumber(n[0]) < 0) then
            local msg, n = pe.errno();
            error('Error reading fd '.. msg);
        elseif (tonumber(n[0]) > 0) then
        end
    until (tonumber(n[0]) == 0)

    local ddata = ffi.new("hex_data_s_type", 0);
    ddata.buf_mem_managed = 1;
    ddata.size = ffi.cast("size_t", n[1]);
    ddata.value = c_buf;

    return ddata;
end

os.r_pclose = function(fd)
    local ret = ffi.C.close(fd);
    if (ret ~= 0) then
        local msg, n = pe.errno();
        error('Error closing fd '.. msg);
    end

    return;
end

--[[
local ret, fd = os.r_popen('ls -lrt');
local buf = os.r_pread(fd);
print(ffi.string(buf.value));
os.r_pclose(fd);
]]

return os;
