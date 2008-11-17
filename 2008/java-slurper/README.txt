SGUser
------

A tiny java utility using google social grpah to get details of a person or
their contacts.

This requires jackson json parser:

http://jackson.codehaus.org/

Usage:

javac -cp .:jackson-asl-0.9.3.jar SGUser.java
java -classpath .:jackson-asl-0.9.3.jar SGUser twitter.com/libbymiller


FoafUser
--------

A tiny java utility that takes a foaf file by url and returns java structures
with useful information in (user details and contacts).

This requires Jena RDF library:

http://jena.sourceforge.net/

- however it's basically a couple of sparql queries.


Usage:

sh foafuser.sh http://swordfish.rdfweb.org/people/libby/rdfweb/webwho.xrdf
