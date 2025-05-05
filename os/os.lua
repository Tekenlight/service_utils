local ffi = require('ffi');
local core_utils = require('lua_schema.core_utils');

ffi.cdef[[
int pipe(int pipefd[2]);
int printf(const char *, ...);
int close(int fd);
int dup2(int oldfd, int newfd);
ssize_t read(int fd, void *buf, size_t count);
ssize_t write(int fd, const void *buf, size_t count);
void *memset(void *s, int c, size_t n);
void *realloc(void *ptr, size_t size);
int mkstemps(char *template, int suffixlen);
char* tempnam(const char *dir, const char *pfx);
void free(void *ptr);
]]

local os_funcs = {
    clock = os.clock,
    difftime = os.difftime,
    execute = os.execute,
    exit = os.exit,
    getenv = os.getenv,
    remove = os.remove,
    rename = os.rename,
    setlocale = os.setlocale,
    time = os.time,
    tmpname = os.tmpname
};

local os = {}
for n,v in pairs(os_funcs) do
    os[n] = v;
end


local unistd = require 'posix.unistd';
local stringx = require('pl.stringx');
local syswait = require('posix.sys.wait');
local pe = require('posix.errno');
local fcntl = require('posix.fcntl');
local sys_stat = require('posix.sys.stat');

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
        if (ret <= 0) then
            error("waitpid call failed, "..errno.. " ["..msg.."]");
        else
            ret = 0;
        end
    else
        error('Unable to fork error:['..pid..']');
    end

    return ret, msg, errno;
end

os.r_popen = function(cmd, inp_data)
    assert(type(cmd) == 'string', 'Invalid input to os.r_popen');
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

os.fd_read = function(fd)
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

os.chrome_name = function()
    local os = core_utils.os_name();
    if (os == 'Darwin') then
        return [[/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome]];
    elseif (os == 'Linux') then
        return "/usr/bin/google-chrome"
    else
        error("OS ["..os.."] not supported");
    end
end

os.open_temp_file = function(prefix, suffix)
    assert(type(prefix) == 'string', "Invalid input to os.open_temp_file");
    assert(type(suffix) == 'string', "Invalid input to os.open_temp_file");

    local template = ffi.cast("char [128]", prefix.."-XXXXXX"..suffix);

    local fd = ffi.C.mkstemps(template, #suffix);
    if (fd < 0) then
        local msg, n = pe.errno();
        error("Error while creating temporary file : "..msg..":"..n);
    end
    return fd, ffi.string(template);
end

os.open_file = function(filename, oflags, mode)
    assert(type(filename) == 'string', "Invalid input to os.open_file");
    assert(mode == nil or type(mode) == 'number', "Invalid input to os.open_file");
    assert(oflags == nil or type(oflags) == 'number', "Invalid input to os.open_file");

    if (oflags == nil) then oflags = fcntl.O_RDONLY; end
    if (mode == nil and (oflags&fcntl.O_CREAT ~= 0)) then
        mode = sys_stat.S_IRUSR | sys_stat.S_IRUSR | sys_stat.S_IRUSR | sys_stat.S_IRUSR;
    end

    local fd, msg, err = fcntl.open(filename, oflags, mode);
    if (fd == nil) then
        error("Error opening file "..filename.." : "..msg..":"..n);
    end

    return fd;
end

os.html_to_pdf = function(filename, props)
    assert(type(filename) == 'string', "Invalid input to os.html_to_pdf");

    local temp_name = ffi.C.tempnam("/tmp", "outfile");
    local out_file_name = ffi.string(temp_name) .. ".pdf"
    ffi.C.free(temp_name);

    local chrome = os.chrome_name();
    local command =
        string.format(chrome .. [[ --headless --disable-gpu --print-to-pdf=]]..out_file_name.." --no-pdf-header-footer "..filename);
    local ret, msg, errno = os.system(command);
    if (ret ~= 0) then
        local msg, n = pe.errno();
        os.system("/usr/bin/rm "..filename);
        error('Error while executing ['..command..']: '.. msg.. ':[ret='..ret..']');
    end

    --[[
    local fd = os.open_file(out_file_name);
    local file_data = os.fd_read(fd);
    ffi.C.close(fd);
    os.system("/usr/bin/rm "..out_file_name);
    ]]
    local file, err = io.open(out_file_name, "rb");
    if (not file) then
        error("Failed to open file: " .. err);
    end

    local file_data = file:read("*all");
    file:close();
    os.system("/usr/bin/rm "..out_file_name);

    return file_data;
end

os.string_html_to_pdf = function(s_html, props)
    assert(type(s_html) == 'string', "Invalid input to os.string_html_to_pdf");

    local fd, filename = os.open_temp_file("/tmp/temp", ".html");
    local ret = ffi.C.write(fd, ffi.cast("char *", s_html), #s_html);
    if (ret < 0) then
        local msg, n = pe.errno();
        ffi.C.close(fd);
        error('Error writing to fd '.. msg);
    end
    ffi.C.close(fd);
    --[[
    local file, err = io.open(filename, "w");
    if (not file) then
        error("Cannot open file: " .. err);
    end
    file:write(s_html);
    file:close();
    --]]

    local out_file_data = os.html_to_pdf(filename, props);

    os.system("/usr/bin/rm "..filename);

    return out_file_data;

end


--[[
local ret, fd = os.r_popen('ls -lrt');
local buf = os.fd_read(fd);
print(ffi.string(buf.value));
os.r_pclose(fd);
]]

return os;
