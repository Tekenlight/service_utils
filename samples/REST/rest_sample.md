This is sample implementation of a REST API


### rest_sample.xsd
```
<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <xsd:element name="rest_sample_struct">
		<xsd:complexType>
			<xsd:sequence>
				<xsd:element name="name" type="xsd:string"/>
				<xsd:element name="address" type="xsd:string"/>
			</xsd:sequence>
		</xsd:complexType>
	</xsd:element>
	<xsd:element name="query_param" type="xsd:string"/>
</xsd:schema>

```

Run the following command
```
gxsd rest_sample.xsd
```

### rest_sample_interface.idl

```
<ns:interface xmlns:ns="http://evpoco.tekenlight.org/idl_spec"
                name="rest_sample" db_schema_name="" package="">
	<documentation>
		ABCD
	</documentation>
    <method name="fetch" transactional="false" http_method="GET">
        <documentation>
			fetch
        </documentation>
        <query_param namespace="" name="query_param" mandatory="false"/>
        <output namespace="" name="rest_sample_struct"/>
    </method>
    <method name="add" transactional="true" http_method="POST">
        <documentation>
            add:
        </documentation>
        <input namespace="" name="rest_sample_struct"/>
	</method>
</ns:interface>

```

run the command 
```
gidl rest_sample_interface.idl
```

### rest_sample.lua
```
local rest_sample = {};

rest_sample.fetch = function (self, context, query_params)
	local data = { name = "Sherlock Holmes" , address = "221B, Baker Street, London" }
	return true, data;
end

rest_sample.add = function (self, context, query_params, rest_sample_struct)
	print(debug.getinfo(1).source, debug.getinfo(1).currentline);
	require 'pl.pretty'.dump(rest_sample_struct);
	print(debug.getinfo(1).source, debug.getinfo(1).currentline);
    return true;

end

return rest_sample; 

```


### evluaserver.properties
```
logging.loggers.root.channel.class = ConsoleChannel
logging.loggers.app.name = Application
logging.loggers.app.channel = c1
logging.formatters.f1.class = PatternFormatter
logging.formatters.f1.pattern = [%p] %t
logging.channels.c1.class = ConsoleChannel
logging.channels.c1.formatter = f1

EVTCPServer.numThreads = 1
EVTCPServer.useIpv6ForConn = 0
EVTCPServer.numConnections = 1000

evlhttprequesthandler.enableluafilecache = false

evluaserver.port   = 9982
evluaserver.networkInterfaceToRunOn= en0, lo0

evluaserver.requestMappingScript = mapper.lua
evluaserver.wsMessageMappingScript = mapper.lua
evluaserver.clMappingScript = evlua_mapper.lua

platform.jwtSignatureKey = example_key

```

Set environmental variable EVLUA_PATH
```
EVLUA_PATH=`pwd`
export EVLUA_PATH
```

Run evluaserver
```
evluaserver -n
```


From another terminal run the curl command to test the server
```
curl -X GET -d$HOME/BIOP/header http://localhost:9982/rest_sample/fetch
```
