#!/usr/bin/env python
#
# Tests for specgen.
#
# trying to test using ...
# http://agiletesting.blogspot.com/2005/01/python-unit-testing-part-1-unittest.html 
# http://docs.python.org/library/unittest.html

# TODO: convert debug print statements to appropriate testing / verbosity logger API
# TODO: make frozen snapshots of some more namespace RDF files
# TODO: find an idiom for conditional tests, eg. if we have xmllint handy for checking output, or rdfa ...

FOAFSNAPSHOT = 'examples/foaf/index-20081211.rdf' # a frozen copy for sanity' sake
 
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

# used in SPARQL queries below
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
    foaf_spec = Vocab(FOAFSNAPSHOT)
    foaf_spec.index()
    foaf_spec.uri = FOAF
    # print "FOAF should be "+FOAF
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

  #reading list: http://tomayko.com/writings/getters-setters-fuxors
  def testCanUseNonStrURI(self):
    """If some fancy object used with a string-oriented setter, we just take the string."""
    doap_spec = Vocab('examples/doap/doap-en.rdf')
    doap_spec.index()
    doap_spec.uri = Namespace('http://usefulinc.com/ns/doap#')  # likely a common mistake
    self.assertEqual(doap_spec.uri, 'http://usefulinc.com/ns/doap#')

  def testFOAFminprops(self):
    """Check we found at least 20 FOAF properties."""
    foaf_spec = Vocab('examples/foaf/index-20081211.rdf')
    foaf_spec.index()
    foaf_spec.uri = str(FOAF)
    c = len(foaf_spec.properties)
   #  print "FOAF property count: ",c
    self.failUnless(c > 20 , "FOAF has more than 20 properties")

  def testFOAFmaxprops(self):
    foaf_spec = Vocab(FOAFSNAPSHOT)
    foaf_spec.index()
    foaf_spec.uri = str(FOAF)
    c = len(foaf_spec.properties)
    # print "FOAF property count: ",c
    self.failUnless(c < 500 , "FOAF has less than 500 properties")


  def testSIOCminprops(self):
    """Check we found at least 20 SIOC properties. If we didn't, known bug. See rdf:Property issue in README.TXT"""
    sioc_spec = Vocab('examples/sioc/sioc.rdf')
    sioc_spec.index()
    sioc_spec.uri = str(SIOC)
    c = len(sioc_spec.properties)
#    print "SIOC property count: ",c
    self.failUnless(c > 20 , "SIOC has more than 20 properties. count was "+str(c))

  def testSIOCmaxprops(self):
    """sioc max props: not more than 500 properties in SIOC"""
    sioc_spec = Vocab('examples/sioc/sioc.rdf')
    sioc_spec.index()
    sioc_spec.uri = str(SIOC)
    c = len(sioc_spec.properties)
    # print "SIOC property count: ",c
    self.failUnless(c < 500 , "SIOC has less than 500 properties. count was "+str(c))


  # work in progress.  
  def testDOAPusingFOAFasExternal(self):
    """when DOAP mentions a FOAF class, the API should let us know it is external"""
    doap_spec = Vocab('examples/doap/doap.rdf')
    doap_spec.index()
    doap_spec.uri = str(DOAP)
    for t in doap_spec.classes:
#      print "is class "+t+" external? "
#      print t.is_external(doap_spec)
      ''

  # work in progress.  
  def testFOAFusingDCasExternal(self):
    """FOAF using external vocabs"""
    foaf_spec = Vocab(FOAFSNAPSHOT)
    foaf_spec.index()
    foaf_spec.uri = str(FOAF)
    for t in foaf_spec.terms:
      # print "is term "+t+" external? ", t.is_external(foaf_spec)
      ''

  def testniceName_1foafmyprop(self):
    """simple test of nicename for a known namespace (FOAF), unknown property"""
    foaf_spec = Vocab(FOAFSNAPSHOT)
    u = 'http://xmlns.com/foaf/0.1/myprop'
    nn = foaf_spec.niceName(u)
    # print "nicename for ",u," is: ",nn
    self.failUnless(nn == 'foaf:myprop', "Didn't extract nicename. input is"+u+"output was"+nn)


  # we test behaviour for real vs fake properties, just in case...
  def testniceName_2foafhomepage(self):
    """simple test of nicename for a known namespace (FOAF), known property."""
    foaf_spec = Vocab(FOAFSNAPSHOT)
    u = 'http://xmlns.com/foaf/0.1/homepage'
    nn = foaf_spec.niceName(u)
    # print "nicename for ",u," is: ",nn
    self.failUnless(nn == 'foaf:homepage', "Didn't extract nicename")

  def testniceName_3mystery(self):
    """simple test of nicename for an unknown namespace"""
    foaf_spec = Vocab(FOAFSNAPSHOT)
    u = 'http:/example.com/mysteryns/myprop'
    nn = foaf_spec.niceName(u)
    # print "nicename for ",u," is: ",nn
    self.failUnless(nn == 'http:/example.com/mysteryns/:myprop', "Didn't extract verbose nicename")

  def testniceName_3baduri(self):
    """niceName should return same string if passed a non-URI (but log a warning?)"""
    foaf_spec = Vocab(FOAFSNAPSHOT)
    u = 'thisisnotauri'
    nn = foaf_spec.niceName(u)
    #  print "nicename for ",u," is: ",nn
    self.failUnless(nn == u, "niceName didn't return same string when given a non-URI")

  def test_set_uri_in_constructor(self):
    """v = Vocab( uri=something ) can be used to set the Vocab's URI. """
    u = 'http://example.com/test_set_uri_in_constructor'
    foaf_spec = Vocab(FOAFSNAPSHOT,uri=u)
    self.failUnless( foaf_spec.uri == u, "Vocab's URI was supposed to be "+u+" but was "+foaf_spec.uri)

  def test_set_bad_uri_in_constructor(self):
    """v = Vocab( uri=something ) can be used to set the Vocab's URI to a bad URI (but should warn). """
    u = 'notauri'
    foaf_spec = Vocab(FOAFSNAPSHOT,uri=u)
    self.failUnless( foaf_spec.uri == u, "Vocab's URI was supposed to be "+u+" but was "+foaf_spec.uri)


  def test_getset_uri(self):
    """getting and setting a Vocab uri property"""
    foaf_spec = Vocab(FOAFSNAPSHOT,uri='http://xmlns.com/foaf/0.1/')
    u = 'http://foaf.tv/example#'
    # print "a) foaf_spec.uri is: ", foaf_spec.uri 
    foaf_spec.uri = u
    # print "b) foaf_spec.uri is: ", foaf_spec.uri 
    # print
    self.failUnless( foaf_spec.uri == u, "Failed to change uri.")

  def test_ns_split(self):
    from libvocab import ns_split
    a,b = ns_split('http://example.com/foo/bar/fee')
    self.failUnless( a=='http://example.com/foo/bar/')
    self.failUnless( b=='fee') # is this a bad idiom? use AND in a single assertion instead?
 
  def test_lookup_Person(self):
    """find a term given it's uri"""
    foaf_spec = Vocab(f=FOAFSNAPSHOT, uri='http://xmlns.com/foaf/0.1/') 
    p = foaf_spec.lookup('http://xmlns.com/foaf/0.1/Person')
    # print "lookup for Person: ",p
    self.assertNotEqual(p.uri,  None, "Couldn't find person class in FOAF")

  def test_lookup_Wombat(self):
    """fail to a bogus term given it's uri"""
    foaf_spec = Vocab(f=FOAFSNAPSHOT, uri='http://xmlns.com/foaf/0.1/') 
    p = foaf_spec.lookup('http://xmlns.com/foaf/0.1/Wombat') # No Wombats in FOAF yet.
    self.assertEqual(p,  None, "lookup for Wombat should return None")

  def test_label_for_foaf_Person(self):
    """check we can get the label for foaf's Person class"""
    foaf_spec = Vocab(f=FOAFSNAPSHOT, uri='http://xmlns.com/foaf/0.1/')
    l = foaf_spec.lookup('http://xmlns.com/foaf/0.1/Person').label
    # print "Label for foaf Person is "+l
    self.assertEqual(l,"Person")

  def test_label_for_foaf_workplaceHomepage(self):
    """check we can get the label for foaf's workplaceHomepage property"""
    foaf_spec = Vocab(f=FOAFSNAPSHOT, uri='http://xmlns.com/foaf/0.1/')
    l = foaf_spec.lookup('http://xmlns.com/foaf/0.1/workplaceHomepage').label
    # print "Label for foaf workplaceHomepage is "+l
    self.assertEqual(l,"workplace homepage")



def suite():
      suite = unittest.TestSuite()
      suite.addTest(unittest.makeSuite(testSpecgen))
      return suite

if __name__ == '__main__':
    print "Running tests..."
    suiteFew = unittest.TestSuite()

#   Add things we know should pass to a subset suite
#   (only skip things we have explained with a todo)
# 
    suiteFew.addTest(testSpecgen("testFOAFns"))
    suiteFew.addTest(testSpecgen("testSIOCns"))
    suiteFew.addTest(testSpecgen("testDOAPns"))
#    suiteFew.addTest(testSpecgen("testCanUseNonStrURI")) # todo: ensure .uri etc can't be non-str
    suiteFew.addTest(testSpecgen("testFOAFminprops"))
#    suiteFew.addTest(testSpecgen("testSIOCminprops")) # todo: improve .index() to read more OWL vocab
    suiteFew.addTest(testSpecgen("testSIOCmaxprops"))



#   run tests we expect to pass:
#    unittest.TextTestRunner(verbosity=2).run(suiteFew)

#   run tests that should eventually pass:
#    unittest.TextTestRunner(verbosity=2).run(suite())


# 
#  or we can run everything:
# http://agiletesting.blogspot.com/2005/01/python-unit-testing-part-1-unittest.html g = foafspec.graph 
#q= 'SELECT ?x ?l ?c ?type WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a ?type . FILTER (?type = owl:ObjectProperty || ?type = owl:DatatypeProperty || ?type = rdf:Property || ?type = owl:FunctionalProperty || ?type = owl:InverseFunctionalProperty) } '
#query = Parse(q)
#relations = g.query(query, initNs=bindings)
#for (term, label, comment) in relations:
#        p = Property(term)
#        print "property: "+str(p) + "label: "+str(label)+ " comment: "+comment

if __name__ == '__main__':

    unittest.main()
