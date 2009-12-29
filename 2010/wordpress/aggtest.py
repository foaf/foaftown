#!/usr/bin/env python

from rdflib.graph import ConjunctiveGraph

# Test basic SPARQL aggregation of the RDFa data
# see also http://identi.ca/notice/17728953 http://identi.ca/notice/17729227

g = ConjunctiveGraph()
g.parse("http://inkdroid.org/journal/network", format='rdfa', lax=True)
g.parse("http://danbri.org/words/network", format='rdfa', lax=True)

#res = g.query("SELECT ?g ?s ?p ?o WHERE { GRAPH ?g { ?s ?p ?o } } ")
#for src, sub, pred, obj in res:
#    print src, sub, pred, obj


q1="""PREFIX foaf: <http://xmlns.com/foaf/0.1/>
SELECT ?src1 ?src2 ?x WHERE {
 GRAPH ?src1 { ?gr1 foaf:member ?x . } 
 GRAPH ?src2 { ?gr2 foaf:member ?x . }  
 FILTER ( ?src1 != ?src2 ) 
 }"""

q1="""PREFIX foaf: <http://xmlns.com/foaf/0.1/>
    SELECT ?src1 ?src2 ?x 
    WHERE {
        GRAPH ?src1 { ?gr1 foaf:member [ foaf:openid ?x ] }
        GRAPH ?src2 { ?gr2 foaf:member [ foaf:openid ?x ] }
        FILTER ( ?src1 != ?src2 )
    }"""

print q1
for src1, src2, x in  g.query(q1):
    print src1, src2, x
