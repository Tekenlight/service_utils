--[[
This tool does

| Stage                          | What happens                         |
| :----------------------------- | :----------------------------------- |
| Launch Chrome headless         | with `--remote-debugging-port`       |
| Discover WebSocket URL         | from `/json/version`                 |
| Create new target (tab)        | `Target.createTarget`                |
| Attach to target               | `Target.attachToTarget`              |
| Use sessionId for all commands | `Page.enable`, `Page.navigate`, etc. |
| Generate PDF                   | `Page.printToPDF`                    |
| Save output cleanly            | Write Base64-decoded PDF             |

Further improvements even more, some ideas:

* Automatically **close** the created tab (`Target.closeTarget`) after PDF generation.
* Add **timeouts** if Chrome does not respond (safety).
* Detect and handle **errors in responses** (sometimes DevTools can send `error` field).
* Add support for **multiple pages / batch PDF generation**.
* Add support for **console logging from Chrome** (`Runtime.consoleAPICalled`).
* Allow **passing print options** (margins, orientation, scale).

It is possible to automate screenshots, JavaScript evaluation, DOM inspection, and more
--]]

local ffi = require('ffi');
local pe = require('posix.errno');
local sc = require('service_utils.REST.external_service_client');
local os = require('service_utils.os');
local ws = require('service_utils.WS.web_socket');
local wu = require('service_utils.WS.ws_util');
local cjson = require('cjson.safe');
local json_parser = cjson.new();
local core_utils = require('lua_schema.core_utils');

ffi.cdef[[
int close(int fd);
ssize_t write(int fd, const void *buf, size_t count);
]]

-- 1. Launch Chrome with remote debugging
local function launch_chrome()
    local chrome_path = "/usr/bin/google-chrome";  -- or "chromium-browser"
    local cmd =
    string.format("%s --headless --disable-gpu --remote-debugging-port=9222 --no-sandbox about:blank 2>/dev/null & echo $!", chrome_path);

    local handle = io.popen(cmd);
    local chrome_pid = tonumber(handle:read("l"));
    handle:close();

    if not chrome_pid then
        error("Failed to launch Chrome!");
    end
    print("Chrome launched with PID:", chrome_pid);

    -- Give it time to start
    platform.ev_hibernate(2);

    return chrome_pid;
end

local function make_connection(chrome_pid)
    local conn, msg = sc.make_connection({
        url = 'localhost',
        port = 9222,
    });
    if (conn == nil) then
        os.execute("kill " .. chrome_pid)
        error("Failed to connect to chrome : "..msg)
    end

    return conn;
end

local function cleanup(chrome_pid, filename)
    os.execute("kill " .. chrome_pid)
    os.execute("rm -f " .. filename)
end

local function from_json(str)
    local stat, obj, err = pcall(json_parser.decode, str);
    assert(stat, tostring(obj).. ": ".. tostring(err));

    return obj;
end

local function to_json(obj)
    local stat, str, err = pcall(json_parser.encode, obj);
    assert(stat, tostring(str) .. ": ".. tostring(err));

    return str;
end

-- 2. Discover the WebSocket Debugger URL
local function get_websocket_debugger_url(conn, chrome_pid, html_url)
    print("Fetch WebSocket URL");

    local status, result, http_status, hdrs, client = 
        sc.generic_transceive(conn, {method = "PUT"}, {}, "/json/version")
    if (not status or http_status ~= 200) then
        cleanup(chrhome_pid, filename);
        error("Failed to fetch Chrome tabs: "..tabs)
    end

    return result.webSocketDebuggerUrl;
end

-- 3. Connect to WebSocket
local function connect_to_chrome(conn, ws_url, chrome_pid, filename)
    -- Connect to Chrome DevTools
    print("Connecting WebSocket...")
    local ws_conn, resp_status, resp_hdrs = ws.connect({
        url = ws_url,
        hdrs = {},
        external = true,
        conn = conn,
    });
    if (ws_conn == nil) then
        cleanup(chrome_pid, filename);
        error("Failed to connect WebSocket: " .. resp_status);
    end
    print("WebSocket connected!")

    return ws_conn;
end

-- 4. Send command and receive response helpers
local function send(ws_conn, method, params, id_counter, session_id)
    local msg = {
        id = id_counter,
        method = method,
        params = params,
        sessionId = session_id,
    }
    local encoded = to_json(msg)
    wu.send_msg(ws_conn, encoded, {
        msg_type = "TEXT"
    });

    return id_counter + 1;
end

local function receive(ws_conn)
    local data = wu.recv_frame(ws_conn);
    if data then
        return from_json(ffi.string(data.buf));
    end
end

local chrome_pdf = {};

chrome_pdf.generate = function(s_html, i_params)
    if (i_params == nil) then i_params = {}; end
    local params = {};

    for i, v in ipairs({
        {'displayHeaderFooter', 'display_header_footer'},
        {'headerTemplate', 'header_template'},
        {'footerTemplate', 'footer_template'},
        {'marginTop', 'margin_top'},
        {'marginBottom', 'margin_bottom'},
        {'marginLeft', 'margin_left'},
        {'marginRight', 'margin_right'},
        {'printBackground', 'print_background'},
        {'paperWidth', 'paper_width'},
        {'paperHeight', 'paper_height'},
        {'pageRanges', 'page_ranges'},
        {'preferCSSPageSize', 'prefer_CSS_page_size'},
        {'scale', 'scale'},
        {'landscape', 'landscape'},
        {'pageRanges', 'page_ranges'},
        {'omitBackground', 'omit_background'},
    }) do
        if (i_params[v[2]] ~= nil) then
            params[v[1]] = i_params[v[2]];
        end
    end

    local fd, filename = os.open_temp_file("/tmp/temp", ".html");
    local ret = ffi.C.write(fd, ffi.cast("char *", s_html), #s_html);
    if (ret < 0) then
        local msg, n = pe.errno();
        ffi.C.close(fd);
        error('Error writing to fd '.. msg);
    end
    ffi.C.close(fd);
    local html_url = 'file://' .. filename;

    local id_counter = 1;
    local stat;

    local chrome_pid = launch_chrome();

    local conn = make_connection(chrome_pid);

    local ws_url = get_websocket_debugger_url(conn, chrome_pid, html_url);
    print("WebSocket URL:", ws_url);

    local ws_conn = connect_to_chrome(conn, ws_url, chrome_pid, filename);
    print("Connected to Chrome DevTools!");

    stat, id_counter = pcall(send, ws_conn, "Target.createTarget", {url = html_url}, id_counter);
    if (not stat) then
        cleanup(chrome_pid, filename);
        error(id_counter);
    end

    local stat, obj = pcall(receive, ws_conn);
    if (not stat) then
        cleanup(chrome_pid, filename);
        error(obj);
    end

    local target_id = obj.result.targetId;

    stat, id_counter = pcall(send, ws_conn, "Target.attachToTarget", {targetId = target_id, flatten = true}, id_counter);
    if (not stat) then
        cleanup(chrome_pid, filename);
        error(id_counter);
    end

    local stat, obj = pcall(receive, ws_conn);
    if (not stat) then
        cleanup(chrome_pid, filename);
        error(obj);
    end

    local session_id = obj.params.sessionId;

    stat, id_counter = pcall(send, ws_conn, "Page.enable", {}, id_counter, session_id);
    if (not stat) then
        cleanup(chrome_pid, filename);
        error(id_counter);
    end

    local stat, obj;
    local counter = 100;
    while true do
        stat, obj = pcall(receive, ws_conn);
        if (not stat) then
            cleanup(chrome_pid, filename);
            error(obj);
        end
        if (obj.method == "Page.loadEventFired" and obj.sessionId == session_id) then
            break
        end
        counter = counter - 1;
        if (counter == 0) then
            cleanup(chrome_pid, filename);
            error("Did not Page.loadEventFired in 100 responses");
        end
    end

    stat, id_counter = pcall(send, ws_conn, "Page.printToPDF", params, id_counter, session_id);
    if (not stat) then
        cleanup(chrome_pid, filename);
        error(id_counter);
    end

    stat, obj, counter = nil, nil, 100;
    while true do
        stat, obj = pcall(receive, ws_conn);
        if (not stat) then
            cleanup(chrome_pid, filename);
            error(obj);
        end
        if (obj.id == (id_counter - 1)) then
            break;
        else
            print("Received event: " .. obj.method);
        end
        counter = counter - 1;
        if (counter == 0) then
            cleanup(chrome_pid, filename);
            error("Did not find proper reply to Page.printToPDF in 100 responses");
        end
    end

    local base64_pdf = obj.result.data
    local pdf_data = core_utils.str_base64_decode(base64_pdf)

    print("Target.closeTarget");
    stat, id_counter = pcall(send, ws_conn, "Target.closeTarget", {
        targetId = target_id
    }, id_counter, session_id);
    if (not stat) then
        cleanup(chrome_pid, filename);
        error(id_counter);
    end

    print("Ack: Target.closeTarget");
    local stat, obj = pcall(receive, ws_conn);
    if (not stat) then
        cleanup(chrome_pid, filename);
        error(obj);
    end

    print("Web socket close");
    wu.close(ws_conn);

    print("Clean up");
    cleanup(chrome_pid, filename);

    return pdf_data;
end

return chrome_pdf;


