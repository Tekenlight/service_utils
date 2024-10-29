local URI_CLASS = require("uri");
local netssl = (require('service_utils.common.utils')).load_library('libevlnetssl');

local client = {}

local mt = { __index = client };
local client_maker = {};

local function get_uri_from_url(url)
    return string.match(url, '[^?]+');
end

local function make_new_http_client(hostname, port, secure, external, timeout, peer_name)
    assert(hostname ~= nil and type(hostname) == 'string', "Invalid hostname");
    assert(port ~= nil and math.type(port) == 'integer', "Invalid port");
    assert(type(secure) == 'boolean', "Invalid secure");
    assert(type(external) == 'boolean', "Invalid external");
    assert(type(timeout) == 'number', "Invalid timeout");
    assert(peer_name == nil or type(peer_name) == 'string', "Invalid peer_name");

    if (secure == nil) then secure = false; end

    local new_client = {};
    new_client = setmetatable(new_client, mt);

    local http_conn, msg, ss, cn = platform.make_http_connection(hostname, port, timeout);

    new_client._http_conn = http_conn;
    new_client._ss = ss;
    new_client._host = tostring(hostname)..':'..tostring(port);
    new_client._send_timeout = timeout;
    new_client._recv_timeout = timeout;
    new_client._ev_conn_stream_sock = cn;

    if (secure) then
        new_client:connect_TLS(peer_name);
        platform.make_http_connection_secure(new_client._http_conn, new_client._ss);
    end

    return new_client;
end

client_maker.deduce_details = function(url, port)
    local uri = URI_CLASS:new(url);
    if (uri._port == nil) then
        if (port ~= nil and tonumber(port) > 0) then
            uri._port = tonumber(port);
        elseif (uri._scheme == 'http') then
            uri._port = 80;
        elseif (uri._scheme == 'https') then
            uri._port = 443;
        else
            error("Unable to deduce port");
        end
    end
    return uri;
end

client_maker.new = function(url, port, secure, external, timeout, peer_name)
    return make_new_http_client(url, port, secure, external, timeout, peer_name);
end

client_maker.new_through_proxy = function(url, port, secure, external, timeout, peer_name)
    return make_new_http_client(url, port, secure, external, timeout, peer_name);
end

client.send_request = function (self, uri, inp_headers, body)
    assert(self ~= nil and type(self) == 'table');
    assert(uri ~= nil and type(uri) == 'string');
    assert(inp_headers ~= nil and type(inp_headers) == 'table');
    assert(body == nil or type(body) == 'string');
    assert(inp_headers.method == 'GET' or inp_headers.method == 'PUT'
            or inp_headers.method == 'POST' or inp_headers.method == 'DELETE');

    local request = platform.new_request();
    request:set_method(inp_headers.method);

    local headers = {};
    for n,v in pairs(inp_headers) do
        headers[n] = v;
    end
    headers.method = nil;

    for n,v in pairs(headers) do
        request:set_hdr_field(n, v);
    end
    request:set_uri(uri);
    request:set_host(self._host);
    --request:set_chunked_trfencoding(true);
    if (body ~= nil) then request:set_content_length(string.len(body)); end
    --request:set_expect_continue(true);
    --request:set_content_type('application/json');

    platform.send_request_header(self._http_conn, request);
    if (body ~= nil) then
        request:write(body);
        platform.send_request_body(self._http_conn, request);
    end

    return;
end

client.connect_TLS = function (self, peer_name)
    netssl.connect_TLS(self._ss, peer_name);
end

client.recv_response = function (self)
    assert(self ~= nil and type(self) == 'table');

    local status, response, msg = pcall(platform.receive_http_response, self._http_conn, self._recv_timeout);
    if (not status) then
        error(response);
    end
    local resp_status = response:get_status();
    local status = true;
    if (math.floor(resp_status / 100) ~= 2) then
        if (math.floor(resp_status) == 101) then
            status = true;
        else
            status = false;
        end
    end
    local resp_buf = '';
    local buf = response:read();
    while (buf ~= nil) do
        resp_buf = resp_buf..buf;
        buf = response:read();
    end
    return status, resp_buf, resp_status, response:get_hdr_fields();
end


return client_maker;

