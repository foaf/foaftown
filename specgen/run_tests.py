#!/usr/bin/env python

# trying to test using ...
# http://agiletesting.blogspot.com/2005/01/python-unit-testing-part-1-unittest.html 
# but getting errors. --danbri
# http://docs.python.org/library/unittest.html
 
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
    print "FOAF should be "+FOAF
    self.assertEqual(str(foaf_spec.uri), 'http://xmlns.com/foaf/0.1/')

  def testSIOCns(self):
    sioc_spec = Vocab('examples/sioc/sioc.rdf')
    sioc_spec.index()
    sioc_spec.uri = str(SIOC)
    self.assertEqual(sioc_spec.uri, 'http://rdfs.org/sioc/ns#')

  def testDOAPWrongns(self):
    doap_spec = Vocab('examples/doap/doap-en.rdf')
    doap_spec.index()
    doap_spec.uri = str(DOAP)
    self.assertNotEqual(doap_spec.uri, 'http://example.com/DELIBERATE_MISTAKE_HERE')

  def testDOAPns(self):
    doap_spec = Vocab('examples/doap/doap-en.rdf')
    doap_spec.index()
    doap_spec.uri = str(DOAP)
    self.assertEqual(doap_spec.uri, 'http://usefulinc.com/ns/doap#')

  # I'd like this to be failing. need to lookup property set/getter stuff in .py
  # then we can trap calls to get/set .uri and str'ify them?
  # 
  def testCanUseNonStrURI(self):
    doap_spec = Vocab('examples/doap/doap-en.rdf')
    doap_spec.index()
    doap_spec.uri = Namespace('http://usefulinc.com/ns/doap#')  # likely a common mistake
    self.assertNotEqual(doap_spec.uri, 'http://usefulinc.com/ns/doap#')

def suite():
      suite = unittest.TestSuite()
      suite.addTest(unittest.makeSuite(testSpecgen))
      return suite

if __name__ == '__main__':
    print "Running tests..."
    suiteFew = unittest.TestSuite()
    suiteFew.addTest(testSpecgen("testFOAFns"))
    suiteFew.addTest(testSpecgen("testSIOCns"))
    suiteFew.addTest(testSpecgen("testDOAPns"))

#    unittest.TextTestRunner(verbosity=2).run(suiteFew)

    unittest.TextTestRunner(verbosity=2).run(suite())


# http://agiletesting.blogspot.com/2005/01/python-unit-testing-part-1-unittest.html g = foafspec.graph 
#q= 'SELECT ?x ?l ?c ?type WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a ?type . FILTER (?type = owl:ObjectProperty || ?type = owl:DatatypeProperty || ?type = rdf:Property || ?type = owl:FunctionalProperty || ?type = owl:InverseFunctionalProperty) } '
#query = Parse(q)
#relations = g.query(query, initNs=bindings)
#for (term, label, comment) in relations:
#        p = Property(term)
#        print "property: "+str(p) + "label: "+str(label)+ " comment: "+comment
