SGUser
------

A tiny java utility using google social grpah to get details of a person or
their contacts.

This requires jackson json parser:

http://jackson.codehaus.org/

Usage:

 javac -cp .:jackson-asl-0.9.3.jar SGUser.java
 java -classpath .:jackson-asl-0.9.3.jar SGUser <flag> <UserId>

Example:

 java -classpath .:jackson-asl-0.9.3.jar SGUser --details http://twitter.com/libbymiller


FoafUser
--------

A tiny java utility that takes a foaf file by url and returns java structures
with useful information in (user details and contacts).

This requires Jena RDF library:

http://jena.sourceforge.net/

- however it's basically a couple of sparql queries.


Usage: 

 sh foafuser.sh <flag> <foafFileURL>

 Available flags are --details and --contacts

Example:

 sh foafuser.sh --details http://swordfish.rdfweb.org/people/libby/rdfweb/webwho.xrdf


QdosUser
--------

A tiny java utility that takes an identifier sends it to Qdos
(http://qdos.com/apps) and returns java structures with useful
information in (user details and contacts).

This requires Jena RDF library:

http://jena.sourceforge.net/

- however it's basically a couple of sparql queries.


Usage: 

 sh qdosuser.sh <flag> <foafFileUserID|email|mboxsha1sum|homepage>

 Available flag is --contacts

Example:

 sh foafuser.sh --contacts http://danbri.org/foaf.rdf#danbri
 sh foafuser.sh --contacts 01e253737c46286ff7cc1183be05ab64fea15438

