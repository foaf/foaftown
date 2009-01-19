Dan Brickley, danbri@danbri.org 

Some misc test files for RDFa 

trying to find an idiom around t6.html that works for xhtml rdfa, and html5 too.

see mime.sh for mimetype svn settings.

focus on t6.html and t7.html (candidate HTML5-friendly idioms)

Tested parsers:

 * rapper (raptor commandline), 1.4.18 (macosx binary), Dave Beckett & Manu Sporny
 * PHP ARC2 - latest version via bengee - triggers rdfa parser when sees xmlns:*  (Shelley, Bengee via mail/irc)
 * pyRdfa - http://www.w3.org/2007/08/pyRdfa/ (online service from Ivan Herman)
 * Jena (Java) GRDDL - uses XSLT, see notes from Damian Steer (*)
 * Perl / Swignition online - http://buzzword.org.uk/swignition/rdfa 
 * rdfa .js bookmarklet - http://www.w3.org/2006/07/SWD/RDFa/impl/js/ 


For real test harness, see http://rdfa.digitalbazaar.com/rdfa-test-harness/



Testing http://svn.foaf-project.org/foaftown/2009/rdfa/tests/t6.html

 - html5-ish text/html)
 - uses xml:http hack.

 Redland/Raptor librdfa (C)		OK (ie. correct 9 triples)
 PHP ARC (latest, via bengee)		OK 	
 pyRdfa online				OK   	(turtle, lax, xhtml) http://www.w3.org/2007/08/pyRdfa/
 Jena GRDDL (tested by Damian Steer(*))	Not OK 
 Perl Swignition online 		Not OK - "<http://www.w3.org/2006/http#//xmlns.com/foaf/0.1/homepage> "
						http://srv.buzzword.org.uk/turtle,strict=Aegu/svn.foaf-project.org/foaftown/2009/rdfa/tests/t6.html
 Javascript RDFa bookmarklets		OK 


Testing http://svn.foaf-project.org/foaftown/2009/rdfa/tests/t7.html

 - exactly as t6.html but with xmlns:http="http:" REMOVED

 Redland/Raptor librdf (C)		NOT OK (0 triples)
 PHP ARC (latest, via bengee)		UNKNOWN
 pyRdfa online				NOT OK
 Jena GRDDL (tested by Damian Steer(*))	Not OK 
  Perl Swignition online 		Not OK - "<http://www.w3.org/2006/http#//xmlns.com/foaf/0.1/homepage> "
						http://srv.buzzword.org.uk/turtle,strict=Aegu/svn.foaf-project.org/foaftown/2009/rdfa/tests/t7.html
 Javascript RDFa bookmarklets		Not OK:   (error: val is null in rdfa.js line: 873)





(*) Java Jena/GRDDL testing from Damian Steer:

	shellac: code was:
[16:31] shellac: require 'java'
[16:31] shellac: m = com.hp.hpl.jena.rdf.model.ModelFactory.create_default_model
[16:31] shellac: r = m.get_reader("GRDDL")
[16:31] shellac: r.set_property("grddl.html-xform",
[16:31] shellac:     "http://ns.inria.fr/grddl/rdfa/2008/09/03/RDFa2RDFXML.xsl")
[16:31] shellac: r.read(m,"http://svn.foaf-project.org/foaftown/2009/rdfa/tests/t6.html")
[16:31] shellac: m.write(java.lang.System.out, "RDF/XML")
[16:32] shellac: (I explicitly set transform from rdfa profile)
[16:33] shellac: Error was:
[16:33] shellac: ; SystemID: http://ns.inria.fr/grddl/rdfa/2008/09/03/RDFa2RDFXML.xsl; Line#: 515; Column#: -1
[16:33] shellac: ERROR [SandBoxed-1] (RDFDefaultErrorHandler.java:40) - Invalid element name. Invalid QName local part {//xmlns.com/foaf/0.1/homepage}
[16:33] shellac: ; SystemID: http://ns.inria.fr/grddl/rdfa/2008/09/03/RDFa2RDFXML.xsl; Line#: 515; Column#: -1
[16:33] shellac: ERROR [main] (RDFDefaultErrorHandler.java:40) - Invalid element name. Invalid QName local part {//xmlns.com/foaf/0.1/homepage}

