# Valid reason for why we went for lua as the language in the backend

1. Should be a scripting language, it therefore brings all the advantages of scripting (therefore python, javascript and lua)
2. Should support multiple threads and not have global interpreter lock (therefore javascript and lua)
3. It should support asynchronous IO (javascript and lua)
4. Good support for coroutines (At this stage  only lua scores, but we will still keep javascript because there are so many open-source and pre-built libraries)
5. Should support types properly (all the types, byte, short, int, long, float, double, arbitrary precision floating points) (javascript and lua fall at this stage)
6. It should be very easy to augment the language with native libraries to capabilities like schema support, type support etc... (lua comes back into the game because of its easy extensibility)
7. Net-net the following from lua and the enhancements, which is not there in other languages
	1. Scripting, therefore easy closures callbacks, dynamic code, faster development
	2. good support for multi-threaded (parallel) event driven code through coroutines
	3. first-class type system support
