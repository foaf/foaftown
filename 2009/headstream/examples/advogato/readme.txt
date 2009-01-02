
You can also test this via WWW version,
roqet -D http://www.advogato.org/person/connolly/foaf.rdf http://svn.foaf-project.org/foaftown/2009/headstream/examples/advogato/advogato2trust.rq
...note that it generates double output for some reason.



This example strips out the piece of an advogato profile that tells you the group they're in. Everything else is discarded.

(aside: I am unsure why the person URIs are not picking up the base URI, but that's not important right now. testing was using Redland/Roqet)

This is also an example of where less-is-more on the Semantic Web. We go from 107 triples per account down to 4 (and it could be down to one).

The essential piece of information is conveyed in a single triple:

	<http://www.advogato.org/ns/trust#Journeyer> <http://xmlns.com/foaf/0.1/member> <http://www.advogato.org/person/danbri/foaf.rdf#me>

...with linked data techniques providing us with more information should we go to look for it.



Airbag:advogato danbri$ rapper --count connolly-adogato-foaf.rdf 
	rapper: Parsing URI file:///Users/danbri/working/foaftown/2009/headstream/examples/advogato/connolly-adogato-foaf.rdf with parser rdfxml
	rapper: Serializing with serializer ntriples
	rapper: Parsing returned 107 triples

Airbag:advogato danbri$ rapper --count connolly-out.rdf 
	rapper: Parsing URI file:///Users/danbri/working/foaftown/2009/headstream/examples/advogato/connolly-out.rdf with parser rdfxml
	rapper: Serializing with serializer ntriples
	rapper: Parsing returned 4 triples


roqet --results rdfxml-abbrev --data file:danbri-adogato-foaf.rdf advogato2trust.rq  http://www.advogato.org/person/danbri/ > danbri-out.rdf



<rdf:RDF
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns="http://xmlns.com/foaf/0.1/" xml:base="http://www.advogato.org/person/danbri/">
  <Person rdf:about="file:///Users/danbri/working/foaftown/2009/headstream/examples/advogato/danbri-advogato-foaf.rdf#me">
    <weblog rdf:resource="diary.html"/>
  </Person>
  <Group rdf:about="../../ns/trust#Journeyer">
    <member rdf:resource="file:///Users/danbri/working/foaftown/2009/headstream/examples/advogato/danbri-advogato-foaf.rdf#me"/>
  </Group>
</rdf:RDF>




roqet --results rdfxml-abbrev --data file:connolly-adogato-foaf.rdf advogato2trust.rq  http://www.advogato.org/person/connolly/ > connolly-out.rdf


<rdf:RDF
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
   xmlns="http://xmlns.com/foaf/0.1/" xml:base="http://www.advogato.org/person/connolly/">
  <Person rdf:about="file:///Users/danbri/working/foaftown/2009/headstream/examples/advogato/connolly-adogato-foaf.rdf#me">
    <weblog rdf:resource="diary.html"/>
  </Person>
  <Group rdf:about="../../ns/trust#Master">
    <member rdf:resource="file:///Users/danbri/working/foaftown/2009/headstream/examples/advogato/connolly-adogato-foaf.rdf#me"/>
  </Group>
</rdf:RDF>
