#!/usr/bin/env python

# queries an RDF quadstore

from rdflib.graph import ConjunctiveGraph

g = ConjunctiveGraph("Sleepycat")
g.open("store", create=True)

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
