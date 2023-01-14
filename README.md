<img src="doc/images/logotk.png" width="200"/>

service_utils are:
------
A set of lua libraries which expose the platform capabilities of [evpoco](https://github.com/Tekenlight/evpoco) to lua programming environment.

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

1. Should be a scripting language, it therefore brings all the advantages of scripting (therefore python, javascript and lua)
2. Should support multiple threads and not have global interpreter lock (therefore javascript and lua)
3. It should support asynchronous IO (javascript and lua)
4. Good support for coroutines (At this stage  only lua scores, but we will still keep javascript because there are so many open-source and pre-built libraries)
5. Should support types properly (all the types, byte, short, int, long, float, double, arbitrary precision floating points) (javascript and lua fall at this stage)
6. It should be very easy to augment the language with native libraries to capabilities like schema support, type support etc... (lua comes back into the game because of its easy extensibility)
7. Net-net the following become available from lua and the enhancements, which is not there in other languages
	1. Scripting, therefore easy closures callbacks, dynamic code, faster development
	2. good support for multi-threaded (parallel) event driven code through coroutines
	3. first-class type system support
	


[Documentation](https://github.com/Tekenlight/service_utils/wiki)
