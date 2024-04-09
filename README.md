<img src="doc/images/logotk.png" width="200"/>

# service\_utils are:
------
A set of lua libraries which expose the platform capabilities of [evpoco](https://github.com/Tekenlight/evpoco) to lua ([evlua](https://github.com/Tekenlight/.github/wiki)) programming environment.

An application developer can use service\_utils togther with [evpoco](https://github.com/Tekenlight/evpoco) in order to develop an application backend and expose them as services or trigger them as a daemon etc.

A set of modules comprising of various utilities needed to develop a web-application are available as part of this library
* REST: Set of classes to deal with client and server side infrastructure code to deal with REST request handling
* SMTP: Set of classes to manage sending of emails
* db: Set of classes to interface with Postgresql and Redis
* jwt: Class to deal with JWT tokens
* WS: Set of classes to deal with client and server sides of websocket protocol
* orm: A set of tools and classes to deal with SELECT/INSERT/UPDATE/DELETE of RDBMS table records.
* crypto: Set of classes to deal with cryptographic encryption and decryption and hashing
* common: Generic utilities namely, message formatting, FILE IO, password generation, connection pool repository, user context

# Why lua?

1. Should be a scripting language because, scripting languages bring a host of advantages to make application development faster and easier, (therefore python, javascript and lua)
2. Should support multiple threads and not have global interpreter lock (therefore javascript and lua)
3. It should support asynchronous IO (javascript and lua)
4. Good support for coroutines (At this stage  only lua scores, but we will still keep javascript because there are so many open-source and pre-built libraries)
5. Should support types properly (all the types, byte, short, int, long, float, double, arbitrary precision floating points) (javascript and lua fall at this stage)
6. It should be very easy to augment the language with native libraries to capabilities like schema support, type support etc... (lua comes back into the game because of its easy extensibility)
7. Net-net the following become available from lua and the enhancements, which is not there in other languages
	1. Scripting, therefore easy closures callbacks, dynamic code, faster development
	2. good support for multi-threaded (parallel) event driven code through coroutines
	3. first-class type system support

# Dependencies
[evpoco](https://github.com/Tekenlight/evpoco) and its dependencies must be downloaded built and installed   
[lua-cjson](https://github.com/Tekenlight/lua-cjson)  
[Penlight](https://github.com/Tekenlight/Penlight)  
[luaposix](https://github.com/Tekenlight/luaposix)  
[lua-uri](https://github.com/Tekenlight/lua-uri): Customised repository  
[luafilesystem](https://github.com/Tekenlight/luafilesystem)  
[markdown](https://github.com/Tekenlight/markdown)  
[ldoc](https://github.com/Tekenlight/LDoc)  

Note: lua-uri has been customized in the fork, hence the fork has to be cloned and installed


# Installation steps

1. Download, build and install evpoco and its dependenies
2. Clone and install lua-uri from Tekenlight (There are a few cusomizations done on the fork)

Assuming evpoco is already installed
```
git clone https://github.com/Tekenlight/lua-uri
cd lua-uri
sudo luarocks make

git clone https://github.com/Tekenlight/service_utils
cd service_utils
sudo luarocks make
```

[Sample REST API](samples/REST/rest_sample.md)


[Documentation](https://github.com/Tekenlight/service_utils/wiki)<br/>
Other links: [evlua documentation](https://github.com/Tekenlight/.github/wiki)
