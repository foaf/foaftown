#!/usr/bin/env python

# total rewrite. --danbri

# Python OO notes:
# http://www.devshed.com/c/a/Python/Object-Oriented-Programming-With-Python-part-1/
# http://www.daniweb.com/code/snippet354.html
# http://docs.python.org/reference/datamodel.html#specialnames
#
# RDFlib:
# http://www.science.uva.nl/research/air/wiki/RDFlib

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
DOAP = Namespace('http:// usefulinc.com/ns/doap#')
# add more here...

import sys, time, re, urllib, getopt
import logging

bindings = { u"xfn": XFN, u"rdf": RDF, u"rdfs": RDFS }

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



class Term:

  def __init__(self, uri='file://dev/null'):
    self.uri = uri
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

  def status(self):
    print 'status is: unknown'

  def __repr__(self):
    return(self.__str__)

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
    s += "\n"
    return s


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



class Vocab:

  def set_filename(self, filename):
    self.filename = filename

  def __init__(self, f='index.rdf'):
    self.graph = rdflib.ConjunctiveGraph()
    self.filename = f
    self.graph.parse(self.filename)
    self.terms = []
    # should also load translations here?
 

  # TODO: default to English
  def index(self):
    g = self.graph
    query = Parse('SELECT ?x ?l ?c WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a rdf:Property } ')
    relations = g.query(query, initNs=bindings)
    for (term, label, comment) in relations:
        p = Property(term)
#        print "Made a property! "+str(p) + "using label: "#+str(label)
        p.label = label
        p.comment = comment
        self.terms.append(p)

    query = Parse('SELECT ?x ?l ?c WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a rdfs:Class } ')
    relations = g.query(query, initNs=bindings)
    for (term, label, comment) in relations:
        c = Class(term)
#        print "Made a class! "+str(p) + "using comment: "+comment
        c.label = label
        c.comment = comment
        self.terms.append(c)
    self.detect_types()
    self.terms.sort()
    self.classes.sort()
    self.properties.sort()

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

  # report what we've parsed from our various sources
  def report(self):
    s = "Report for vocabulary from " + self.filename + "\n"
    if self.uri != None:
      s += "URI: " + self.uri + "\n\n"
    for t in self.terms:
      s += t.simple_report()
    return s

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

