JQbus - Jabber chat for query services

We use off-the-shelf Jabber chat services as a generic information bus, passing SPARQL queries and
results via user accounts, encoded as XMPP IQ messages.

See pages at http://svn.foaf-project.org/foaftown/jqbus/intro.html

(I may migrate text from README.txt into there... for now, read both!)

Contact: Dan Brickley <http://danbri.org/> 
	email: danbri@danbri.org 
	(please cc: danbrickley@gmail.com if I might not know your email address yet)


How does it look?

A Jabber (ie. XMPP) client maintains an XML-based conversation with a service connection. It is  
something like a never-ending streamed XML document. Here is an "IQ" stanza within such a 
conversation, from the point of view of the sender:

<iq id="S3IG2-4" to="danbri@livejournal.com/sparqlserver" type="get">
<query xmlns='http://www.w3.org/2005/09/xmpp-sparql-binding'>
PREFIX foaf: &lt;http://xmlns.com/foaf/0.1/&gt; SELECT DISTINCT ?p ?o WHERE {?s foaf:name ?o.}
</query>

Here is how that looks to the receiving party:

<iq id="40z5D-4" to="danbri@livejournal.com/sparqlserver" from="bandri@livejournal.com/sparqlclient" type="get">
<query xmlns="http://www.w3.org/2005/09/xmpp-sparql-binding">
PREFIX foaf: &lt;http://xmlns.com/foaf/0.1/&gt; SELECT DISTINCT ?p ?o WHERE {?s foaf:name ?o.}
</query>
</iq>

Note I'm testing with two LiveJournal accounts, here "bandri" is asking questions of "danbri"; it should be 
possible to use jabber.org, gmail/gtalk and other providers, so long as the Jabber servers are federated fully. You can see 
that the data is pretty much unchanged, except that a different stream-specific id is used in each. The id serves to
tie together a conversation across various XML elements, locally between a Jabber client and its service provider. Looking to 
the response format, again from the querying party's perspect, we see:

<iq id="40z5D-4" to="bandri@livejournal.com/sparqlclient" from="danbri@livejournal.com/sparqlserver" type="result">
<query-result xmlns="http://www.w3.org/2005/09/xmpp-sparql-binding">
<meta comments="content generated via DOM conversion."/>
<sparql xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xs="http://www.w3.org/2001/XMLSchema#" xmlns="http://www.w3.org/2005/sparql-results#">
  <head>
    <variable name="p"/>
    <variable name="o"/>
  </head>
  <results>
    <result>
      <binding name="o">
        <literal>Libby Miller</literal>
      </binding>
    </result>
    <result>
      <binding name="o">
        <literal>Tim Berners-Lee</literal>
      </binding>
    </result>
<!-- ... more bindings here -->
  </results>
</sparql>
</query-result>
</iq>

Note: the markup here is as specified for the XML results format, but embedded within a broader protocol context. 
The initial design used <query> elements for both the question and response. The current design uses different 
XML element names; this was largely motivated by implementation pragmatics w.r.t. the Smack library and the way
it attaches custom handlers to IQ messages. But it also makes some sense intuitively; a response is not a query.

The Python code at http://crschmidt.net/semweb/sparqlxmpp/ uses a slightly different binding:

	<iq to='crschmidt@crschmidt.net/sparql' type='result' id='2' from='crschmidt@crschmidt.net/sparql'>
	<query xmlns='http://www.w3.org/2005/09/xmpp-sparql-binding'>
	<meta />
	<sparql xmlns='http://www.w3.org/2001/sw/DataAccess/rf1/result'>
	  <head> ...




JQbus Details: Getting Started

The build.xml supplied here should get you running, assuming a Java 5 system. You can 
do something like JAVA_HOME=/usr in ~/.ant/ant.conf to avoid ant using an earlier Java, 
if needed.

Typing "ant build" in the top level directory should "just work". The javadoc
can be regenerated with "ant javadoc". To do anything useful, you will need to
be able to build the code, since account details are currently hardcoded in the src.

You will also need to either be online, or have a private Jabber server running locally.

Prequisites:

 * two Jabber accounts that can exchange IQ messages (not clear if GTalk works)
 * their passwords 

Currently, client/server roles in a conversation are hardcoded from the main test script,
ie. FoafJabberNode. The role and password are passed in from this build script:

    ant -Dfoaftown.pwd=$P -Dfoaftown.role=server
    ant -Dfoaftown.pwd=$P -Dfoaftown.role=client

(hackily passing in a password from an env variable, not 100% wise... can also
store foaftown.pwd=PASSWORD in build.properties, also risky with "real" accounts.)

The underlying Smack library will popup a Java GUI window for client and server,
providing a nice log of messages sent back-and-forth. Experiment by hacking the 
FoafJabberNode.java and rebuilding; this file is responsible for setting up the 
behaviour of client and server, including attachment of data sources, and decision 
of whether or not to accept a query.



Further Work

* There is no decent error handling - at code level, or in the protocol.

* There is no slick example yet of hooking up some code to get called once we have a 
response.

* We don't yet use persistent storage in Jena. We should try SDB.

* We don't yet have ANY access control.

* We don't make use of the nice GUI for SPARQL results contrib'd by Leigh from Twinkle code.

* We should restore interop with the Python implementation, dig out the Perl (swh/ericp?), ...

* Unit tests would be nice :)

We need to think about named graph URIs that might be standard for common "personal semweb"
fields, such as contact book, photos, calendar, pgp-checks, crawled YASNs. Maybe some
commonality with KDE work? More needed also on discovery - eg. can we always list 
the named graphs in some store? (check SPARQL spec).

Old CVS:* http://rdfweb.org/viewcvs/viewcvs.cgi/foafproject/htdocs/2005/code/foaftown/jabber/

The URI http://www.w3.org/2005/09/xmpp-sparql-binding is
used to give XMPP a name for the extensions to <iq> used; however note that
these are in flux and shouldn't yet be relied on in production code. Also note that the above URI
and associated protocol/binding design hasn't been reviewed by SPARQL or XMPP 
experts. 

Links and logs:
  http://www.ilrt.bris.ac.uk/discovery/chatlogs/swig/2005-09-06#T18-24-56 see
  http://www.saint-andre.com/blog/2005-08.html#2005-08-30T12:07
  http://www.jivesoftware.org/builds/smack/docs/latest/documentation/index.html
  http://www.jivesoftware.org/builds/smack/docs/latest/documentation/roster.html
  http://www.jivesoftware.org/builds/smack/docs/latest/documentation/providers.html

todo: 

find credits for the xmlpull library ("public domain") used. consider making a .jar instead? 
packaged with the app here 'cos it didn't have a domain-based package name.

Fix build.xml to do something like this, or read subversion manual:

    find . -name \*.html -exec svn propset svn:mime-type text/html {} \;
    find . -name \*.png -exec svn propset svn:mime-type image/png {} \;
    find . -name \*.jpg -exec svn propset svn:mime-type image/jpeg {} \;

and this

 cd ..; tar -zcvf downloads/jqbus-latest.tar.gz jqbus/

Notes with stpeter:

is there a (practical? official?) limit to IQ message size? just beginning cross-client tests:
Ouch, network error
Error: 1, Query:
SELECT DISTINCT ?x ?y WHERE {?x <http://www.w3.org/2004/02/skos/core#broader> ?y .}
hmm
on jabber.org we limit packet sizes to 65k
...using Chris Schmidt's Python server code, it died before it got the response out
so i'd need to keep packets < both LJ's and GTalk's?
well, they may not impose such limits
not sure about their services
there's no hard limit in the protocol

