#!/usr/bin/env python

# trying to test using ...
# http://agiletesting.blogspot.com/2005/01/python-unit-testing-part-1-unittest.html 
# but getting errors. --danbri
 
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

bindings = { u"xfn": XFN, u"rdf": RDF, u"rdfs": RDFS, u"owl": OWL, u"doap": DOAP, u"sioc": SIOC, u"foaf": FOAF }

import rdflib
from rdflib import Namespace
from rdflib.Graph import Graph
from rdflib.Graph import ConjunctiveGraph
from rdflib.sparql.sparqlGraph  import SPARQLGraph
from rdflib.sparql.graphPattern import GraphPattern
from rdflib.sparql.bison import Parse 
from rdflib.sparql import Query 


import unittest

class testSpecgen(unittest.TestCase):

  """a test class for Specgen"""



def setUp(self):
  """set up data used in the tests. Called  before each test function execution."""

def testFOAFns(self):
  foaf_spec = Vocab('examples/foaf/index.rdf')
  foaf_spec.index()
  foaf_spec.uri = FOAF

  self.assertEqual(foaf_spec.uri, 'http://xmlns.com/foaf/0.1/')


def testSIOCns(self):
  sioc_spec = Vocab('examples/sioc/sioc.rdf')
  sioc_spec.index()
  sioc_spec.uri = SIOC

def testDOAPns(self):
  doap_spec = Vocab('examples/doap/doap-en.rdf')
  doap_spec.index()
  doap_spec.uri = DOAP
  self.assertEqual(doap_spec.uri, 'http://example.com/nothere')


def suite():
    suite = unittest.TestSuite()
    suite.addTest(unittest.makeSuite(testSpecgen))
    return suite

if __name__ == '__main__':

    suiteFew = unittest.TestSuite()
    suiteFew.addTest(testSpecgen("testFOAFns"))

# http://agiletesting.blogspot.com/2005/01/python-unit-testing-part-1-unittest.html g = foafspec.graph 
#q= 'SELECT ?x ?l ?c ?type WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a ?type . FILTER (?type = owl:ObjectProperty || ?type = owl:DatatypeProperty || ?type = rdf:Property || ?type = owl:FunctionalProperty || ?type = owl:InverseFunctionalProperty) } '
#query = Parse(q)
#relations = g.query(query, initNs=bindings)
#for (term, label, comment) in relations:
#        p = Property(term)
#        print "property: "+str(p) + "label: "+str(label)+ " comment: "+comment

#  """set up data used in the tests. Called  before each test function execution."""
