#!/usr/bin/env python

# total rewrite. --danbri

# Usage:
#
# >>> from libvocab import Vocab, Term, Class, Property
#
# >>> from libvocab import Vocab, Term, Class, Property
# >>> v = Vocab( f='examples/foaf/index.rdf', uri='http://xmlns.com/foaf/0.1/')
# >>> dna = v.lookup('http://xmlns.com/foaf/0.1/dnaChecksum')
# >>> dna.label
#     'DNA checksum'
# >>> dna.comment
#     'A checksum for the DNA of some thing. Joke.'
# >>> dna.id
#     u'dnaChecksum'
# >>> dna.uri
#     'http://xmlns.com/foaf/0.1/dnaChecksum'
#
#
# Python OO notes:
# http://www.devshed.com/c/a/Python/Object-Oriented-Programming-With-Python-part-1/
# http://www.daniweb.com/code/snippet354.html
# http://docs.python.org/reference/datamodel.html#specialnames
#
# RDFlib:
# http://www.science.uva.nl/research/air/wiki/RDFlib
#
# http://dowhatimean.net/2006/03/spellchecking-vocabularies-with-sparql
#
# We define basics, Vocab, Term, Property, Class
# and populate them with data from RDF schemas, OWL, translations ... and nearby html files.

import rdflib
from rdflib import Namespace
from rdflib.Graph import Graph
from rdflib.Graph import ConjunctiveGraph
from rdflib.sparql.sparqlGraph  import SPARQLGraph
from rdflib.sparql.graphPattern import GraphPattern
from rdflib.sparql.bison import Parse 
from rdflib.sparql import Query 

FOAF = Namespace('http://xmlns.com/foaf/0.1/')
RDFS = Namespace('http://www.w3.org/2000/01/rdf-schema#')
XFN  = Namespace("http://gmpg.org/xfn/1#")
RDF  = Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
OWL = Namespace('http://www.w3.org/2002/07/owl#')
VS = Namespace('http://www.w3.org/2003/06/sw-vocab-status/ns#')
DC = Namespace('http://purl.org/dc/elements/1.1/')
DOAP = Namespace('http://usefulinc.com/ns/doap#')
SIOC = Namespace('http://rdfs.org/sioc/ns#')
SIOCTYPES = Namespace('http://rdfs.org/sioc/types#')
SIOCSERVICES = Namespace('http://rdfs.org/sioc/services#')
#
# TODO: rationalise these two lists. or at least check they are same.

ns_list = { "http://www.w3.org/1999/02/22-rdf-syntax-ns#"   : "rdf",
            "http://www.w3.org/2000/01/rdf-schema#"         : "rdfs",
            "http://www.w3.org/2002/07/owl#"                : "owl",
            "http://www.w3.org/2001/XMLSchema#"             : "xsd",
            "http://rdfs.org/sioc/ns#"                      : "sioc",
            "http://xmlns.com/foaf/0.1/"                    : "foaf", 
            "http://purl.org/dc/elements/1.1/"              : "dc",
            "http://purl.org/dc/terms/"                     : "dct",
            "http://usefulinc.com/ns/doap#"                 : "doap",
            "http://www.w3.org/2003/06/sw-vocab-status/ns#" : "status",
            "http://purl.org/rss/1.0/modules/content/"      : "content", 
            "http://www.w3.org/2003/01/geo/wgs84_pos#"      : "geo",
            "http://www.w3.org/2004/02/skos/core#"          : "skos"
          }


import sys, time, re, urllib, getopt
import logging

bindings = { u"xfn": XFN, u"rdf": RDF, u"rdfs": RDFS, u"vs": VS }

#g = None

def speclog(str):
  sys.stderr.write("LOG: "+str+"\n")


# a Term has... (intrinsically and via it's RDFS/OWL description)
# uri - a (primary) URI, eg. 'http://xmlns.com/foaf/0.1/workplaceHomepage'
# id - a local-to-spec ID, eg. 'workplaceHomepage'
# xmlns - an xmlns URI (isDefinedBy, eg. 'http://xmlns.com/foaf/0.1/')
# 
# label  - an rdfs:label 
# comment - an rdfs:comment
#
# Beyond this, properties vary. Some have vs:status. Some have owl Deprecated.
# Some have OWL descriptions, and RDFS descriptions; eg. property range/domain
# or class disjointness.

def ns_split(uri):
   regexp = re.compile( "^(.*[/#])([^/#]+)$" )
   rez = regexp.search( uri )
   return(rez.group(1), rez.group(2))



class Term(object):

  def __init__(self, uri='file://dev/null'):
    self.uri = str(uri)
    self.uri = self.uri.rstrip()

    # speclog("Parsing URI " + uri)
    a,b = ns_split(uri)
    self.id = b
    self.xmlns = a
    if self.id==None:
      speclog("Error parsing URI. "+uri)
    if self.xmlns==None:
      speclog("Error parsing URI. "+uri)
    # print "self.id: "+ self.id + " self.xmlns: " + self.xmlns

  def uri(self):
    try:
      s = self.uri
    except NameError:
      self.uri = None
      s = '[NOURI]'
      speclog('No URI for'+self)
    return s

  def id(self):
    print "trying id"
    try:
      s = self.id
    except NameError:
      self.id = None
      s = '[NOID]'
      speclog('No ID for'+self)
    return str(s)

  def is_external(self, vocab):
    print "Comparing property URI ",self.uri," with vocab uri: " + vocab.uri
    return(False)

  #def __repr__(self):
  #  return(self.__str__)

  def __str__(self):
    try:
      s = self.id
    except NameError:
      self.label = None
      speclog('No label for '+self+' todo: take from uri regex')
      s = (str(self))
    return(str(s))

 # so we can treat this like a string 
  def __add__(self, s):
    return (s+str(self))
 
  def __radd__(self, s):
    return (s+str(self))

  def simple_report(self):
    t = self
    s=''
    s +=  "default: \t\t"+t +"\n"
    s +=  "id:      \t\t"+t.id +"\n"
    s += "uri:     \t\t"+t.uri +"\n"
    s += "xmlns:   \t\t"+t.xmlns +"\n"
    s += "label:   \t\t"+t.label +"\n"
    s += "comment: \t\t" + t.comment +"\n"
    s += "status: \t\t" + t.status +"\n"
    s += "\n"
    return s


  def _get_status(self):
    try:
      return self._status
    except:
      return 'unknown'

  def _set_status(self, value):
    self._status = str(value)

  status = property(_get_status,_set_status)



# a Python class representing an RDFS/OWL property.
# 
class Property(Term):

  # OK OK but how are we SUPPOSED to do this stuff in Python OO?. Stopgap.
  def is_property(self):
    # print "Property.is_property called on "+self
    return(True)

  def is_class(self):
    # print "Property.is_class called on "+self
    return(False)





# A Python class representing an RDFS/OWL class
#

class Class(Term):

  # OK OK but how are we SUPPOSED to do this stuff in Python OO?. Stopgap.
  def is_property(self):
    # print "Class.is_property called on "+self
    return(False)

  def is_class(self):
    # print "Class.is_class called on "+self
    return(True)









# A python class representing (a description of) some RDF vocabulary
#
class Vocab(object):

  def __init__(self, f='index.rdf'  ,  uri=None ):
    self.graph = rdflib.ConjunctiveGraph()
    self.filename = f
    self._uri = uri
    self.graph.parse(self.filename)
    self.terms = []
    # should also load translations here?

    if f != None:    
      self.index()

  # TODO: python question - can we skip needing getters? and only define setters. i tried/failed. --danbri
  def _get_uri(self):
        return self._uri

  def _set_uri(self, value):
    v = str(value) # we don't want Namespace() objects and suchlike, but we can use them without whining.
    if ':' not in v:
      speclog("Warning: this doesn't look like a URI: "+v)
      # raise Exception("This doesn't look like a URI.")
    self._uri = str( value )

  uri = property(_get_uri,_set_uri)

  def set_filename(self, filename):
    self.filename = filename

  # TODO: be explicit if/where we default to English
  # TODO: do we need a separate index(), versus just use __init__ ?
  def index(self):
    #    speclog("Indexing description of "+str(self))

    # blank down anything we learned already

    self.terms = []
    self.properties = []
    self.classes = []

    g = self.graph
    query = Parse('SELECT ?x ?l ?c WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a rdf:Property } ')
    relations = g.query(query, initNs=bindings)
    for (term, label, comment) in relations:
        p = Property(term)
#        print "Made a property! "+str(p) + "using label: "#+str(label)
        p.label = str(label)
        p.comment = str(comment)
        self.terms.append(p)

    query = Parse('SELECT ?x ?l ?c WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a ?type  FILTER (?type = <http://www.w3.org/2002/07/owl#Class> || ?type = <http://www.w3.org/2000/01/rdf-schema#Class> ) }')
    relations = g.query(query, initNs=bindings)
    for (term, label, comment) in relations:
        c = Class(term)
#        print "Made a class! "+str(p) + "using comment: "+comment
        c.label = str(label)
        c.comment = str(comment)
        self.terms.append(c)
    self.detect_types()
    self.terms.sort()
    self.classes.sort()
    self.properties.sort()


    # http://www.w3.org/2003/06/sw-vocab-status/ns#"
    query = Parse('SELECT ?x ?vs WHERE { ?x <http://www.w3.org/2003/06/sw-vocab-status/ns#term_status> ?vs }')
    status = g.query(query, initNs=bindings) 
    # print "status results: ",status.__len__()
    for x, vs in status:
      # print "STATUS: ",vs, " for ",x
      t = self.lookup(x)
      if t != None:
        t.status = vs
        # print "Set status.", t.status
      else:
        speclog("Couldn't lookup term: "+x)

    # Go back and see if we missed any properties defined in OWL. TODO: classes too. Or rewrite above SPARQL. addd more types for full query.
    q= 'SELECT ?x ?l ?c WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a ?type .  FILTER (?type = <http://www.w3.org/2002/07/owl#ObjectProperty>)}'
    q= 'SELECT distinct ?x ?l ?c WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a ?type . FILTER (?type = <http://www.w3.org/2002/07/owl#ObjectProperty> || ?type = <http://www.w3.org/2002/07/owl#DatatypeProperty> || ?type = <http://www.w3.org/1999/02/22-rdf-syntax-ns#Property> || ?type = <http://www.w3.org/2002/07/owl#FunctionalProperty> || ?type = <http://www.w3.org/2002/07/owl#InverseFunctionalProperty>) } '

    query = Parse(q)
    relations = g.query(query, initNs=bindings)
    for (term, label, comment) in relations:
        p = Property(str(term))
        got = self.lookup( str(term) )
        if got==None:
          # print "Made an OWL property! "+str(p.uri) 
          p.label = str(label)
          p.comment = str(comment)
          self.terms.append(p)

    self.detect_types() # probably important 
    self.terms.sort()   # does this even do anything? 
    self.classes.sort()
    self.properties.sort()

  # todo, use a dictionary index instead. RTFM.
  def lookup(self, uri):
    uri = str(uri)
    for t in self.terms:
      # print "Lookup: comparing '"+t.uri+"' to '"+uri+"'"
      # print "type of t.uri is ",t.uri.__class__
      if t.uri==uri:
        # print "Matched."  # should we str here, to be more liberal?
        return t
      else:
        # print "Fail."
        ''
    return None

  # print a raw debug summary, direct from the RDF
  def raw(self):
    g = self.graph
    query = Parse('SELECT ?x ?l ?c WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c  } ')
    relations = g.query(query, initNs=bindings)
    print "Properties and Classes (%d terms)" % len(relations) 
    print 40*"-"
    for (term, label, comment) in relations:
        print "term %s l: %s \t\tc: %s " % (term, label, comment)
    print

   # TODO: work out how to do ".encode('UTF-8')" here

  # report what we've parsed from our various sources
  def report(self):
    s = "Report for vocabulary from " + self.filename + "\n"
    if self.uri != None:
      s += "URI: " + self.uri + "\n\n"
    for t in self.terms:
      s += t.simple_report()
    return s

  # for debugging only
  def detect_types(self):
    self.properties = []
    self.classes = []
    for t in self.terms:
      # print "Doing t: "+t+" which is of type " + str(t.__class__)
      if t.is_property():
        # print "is_property."
        self.properties.append(t)
      if t.is_class():
        # print "is_class."
        self.classes.append(t)


# CODE FROM ORIGINAL specgen:

 
  def niceName(self, uri = None ):
    if uri is None: 
      return
    # speclog("Nicing uri "+uri)
    regexp = re.compile( "^(.*[/#])([^/#]+)$" )
    rez = regexp.search( uri )  
    if rez == None:
      # print "Failed to niceName. Returning the whole thing."
      return(uri)   
    pref = rez.group(1)
    # todo: make this work when uri doesn't match the regex --danbri
    # AttributeError: 'NoneType' object has no attribute 'group'
    return ns_list.get(pref, pref) + ":" + rez.group(2)



  # HTML stuff, should be a separate class

  def azlist(self):
    """Builds the A-Z list of terms"""
    az = """<div class="azlist">"""
    az = """%s\n<p>Classes: |""" % az
    c_ids = []
    p_ids = []

    for p in self.properties:
    #  print "Storing property: ", p   
      p_ids.append(str(p.id))

    for c in self.classes:
    #  print "Storing class: ", c
      c_ids.append(str(c.id))
 
    print 
    print "c_ids is ", c_ids.sort()

    print "ALL"
    print c_ids, p_ids

    c_ids.sort()
    for c in c_ids:
        print("Class "+c+" in az generation.")
        az = """%s <a href="#term_%s">%s</a> | """ % (az, str(c).replace(" ", ""), c)

    az = """%s\n</p>""" % az
    az = """%s\n<p>Properties: |""" % az
    print "p_ids is ", p_ids.sort()

    p_ids.sort()
    for p in p_ids:
        speclog("Property "+p+" in az generation.")
        az = """%s <a href="#term_%s">%s</a> | """ % (az, str(p).replace(" ", ""), p)
    az = """%s\n</p>""" % az
    az = """%s\n</div>""" % az

    return az


