#!/usr/bin/env python

__all__ = [ 'main' ]



#  Utility for testing sparql queries against data
#
#  eg. we can diagnose why we found no SIOC properties here. 
# Answer: the RDFS/OWL only uses OWL DL.


import libvocab
from libvocab import Vocab
from libvocab import Term
from libvocab import Class
from libvocab import Property
from libvocab import SIOC
from libvocab import OWL
from libvocab import FOAF
from libvocab import RDFS
from libvocab import RDF
from libvocab import DOAP
from libvocab import XFN

bindings = { u"xfn": XFN, u"rdf": RDF, u"rdfs": RDFS, u"owl": OWL }

import rdflib
from rdflib import Namespace
from rdflib.Graph import Graph
from rdflib.Graph import ConjunctiveGraph
from rdflib.sparql.sparqlGraph  import SPARQLGraph
from rdflib.sparql.graphPattern import GraphPattern
from rdflib.sparql.bison import Parse 
from rdflib.sparql import Query 

# Test a SPARQL query against RDF data input
#

fn = 'examples/sioc/sioc.rdf'
#fn = 'examples/foaf/index.rdf'
#fn = 'examples/doap/doap-en.rdf'

spec = Vocab( fn )
spec.uri = SIOC
# spec.raw()
spec.index() # slurp info from sources
#print spec.report().encode('UTF-8')

g = spec.graph 
q= 'SELECT ?x ?l ?c ?type WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a ?type . FILTER (?type = owl:ObjectProperty || ?type = owl:DatatypeProperty || ?type = rdf:Property || ?type = owl:FunctionalProperty || ?type = owl:InverseFunctionalProperty) } '

q= 'SELECT distinct ?x ?l ?c WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a ?type . FILTER (?type = <http://www.w3.org/2002/07/owl#ObjectProperty> || ?type = <http://www.w3.org/2002/07/owl#DatatypeProperty> || ?type = <http://www.w3.org/1999/02/22-rdf-syntax-ns#Property> || ?type = <http://www.w3.org/2002/07/owl#FunctionalProperty> || ?type = <http://www.w3.org/2002/07/owl#InverseFunctionalProperty>) } '


# Got type: http://www.w3.org/2002/07/owl#ObjectProperty
# property: has_usergrouplabel: has_usergroup comment: Points to a Usergroup that has certain access to this Space.


query = Parse(q)
relations = g.query(query, initNs=bindings)
for (term, label, comment) in relations:
        p = Property(term)
        print "property: "+str(p) + "label: "+str(label)+ " comment: "+comment
