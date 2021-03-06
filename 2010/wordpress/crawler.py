#!/usr/bin/env python

from rdflib.graph import ConjunctiveGraph

# Test basic SPARQL aggregation of the RDFa data
# see also http://identi.ca/notice/17728953 http://identi.ca/notice/17729227

g = ConjunctiveGraph("Sleepycat")
g.open("store", create=True)
g.parse("http://inkdroid.org/journal/network", format='rdfa', lax=True)
#g.parse("http://danbri.org/words/network", format='rdfa', lax=True)
g.parse("http://danbri.org/words/2009/12/29/523", format='rdfa', lax=True)
g.parse("http://melvincarvalho.com/blog/installed-f2f-plugin/", format='rdfa', lax=True)

q1="""PREFIX foaf: <http://xmlns.com/foaf/0.1/>
    SELECT ?src1 ?src2 ?x 
    WHERE {
        GRAPH ?src1 { ?gr1 foaf:member [ foaf:openid ?x ] }
        GRAPH ?src2 { ?gr2 foaf:member [ foaf:openid ?x ] }
        FILTER ( ?src1 != ?src2 )
    }"""

for src1, src2, x in  g.query(q1):
    print src1, src2, x

g.close() 
