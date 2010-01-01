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

from rdflib.namespace import Namespace
from rdflib.graph import Graph, ConjunctiveGraph
from rdflib.sparql.sparqlGraph  import SPARQLGraph
from rdflib.sparql.graphPattern import GraphPattern
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


import sys, time, re, urllib, getopt
import logging
import os.path
import cgi
import operator

bindings = { u"xfn": XFN, u"rdf": RDF, u"rdfs": RDFS, u"vs": VS }

#g = None

def speclog(str):
  sys.stderr.write("LOG: "+str+"\n")

# todo: shouldn't be foaf specific
def termlink(text):
  result = re.sub( r"<code>foaf:(\w+)<\/code>", r"<code><a href='#term_\g<1>'>\g<1></a></code>", text )
  return result

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

  def __init__(self, dir, f='index.rdf', uri=None ):
    self.graph = ConjunctiveGraph()
    self._uri = uri
    self.dir = dir
    self.filename = os.path.join(dir, f) 
    self.graph.parse(self.filename)
    self.terms = []
    self.uterms = []
    # should also load translations here?
    # and deal with a base-dir?

    ##if f != None:    
    ##  self.index()
    self.ns_list = { "http://www.w3.org/1999/02/22-rdf-syntax-ns#"   : "rdf",
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
            "http://www.w3.org/2004/02/skos/core#"          : "skos",
            "http://purl.org/NET/c4dm/event.owl#"           : "event"
          }



  def addShortName(self,sn):
    self.ns_list[self._uri] = sn
    self.shortName = sn
    #print self.ns_list

  # not currently used
  def unique_terms(self):
    tmp=[]
    for t in list(set(self.terms)):
      s = str(t)
      if (not s in tmp): 
        self.uterms.append(t)
        tmp.append(s)

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
    tmpclasses=[]
    tmpproperties=[]

    g = self.graph

    query = 'SELECT ?x ?l ?c WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a rdf:Property }'

    relations = g.query(query, initNs=bindings)
    for (term, label, comment) in relations:
        p = Property(term)
#        print "Made a property! "+str(p) + "using label: "#+str(label)
        p.label = str(label)
        p.comment = str(comment)
        self.terms.append(p)
        if (not str(p) in tmpproperties): 
          tmpproperties.append(str(p))
          self.properties.append(p)

    query = 'SELECT ?x ?l ?c WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a ?type  FILTER (?type = <http://www.w3.org/2002/07/owl#Class> || ?type = <http://www.w3.org/2000/01/rdf-schema#Class> ) }'
    relations = g.query(query, initNs=bindings)
    for (term, label, comment) in relations:
        c = Class(term)
#        print "Made a class! "+str(p) + "using comment: "+comment
        c.label = str(label)
        c.comment = str(comment)
        self.terms.append(c)
        if (not str(c) in tmpclasses): 
          self.classes.append(c)
          tmpclasses.append(str(c))

    self.terms.sort(key=operator.attrgetter('id'))
    self.classes.sort(key=operator.attrgetter('id'))
    self.properties.sort(key=operator.attrgetter('id'))

    # http://www.w3.org/2003/06/sw-vocab-status/ns#"
    query = 'SELECT ?x ?vs WHERE { ?x <http://www.w3.org/2003/06/sw-vocab-status/ns#term_status> ?vs }'
    status = g.query(query, initNs=bindings) 
    # print "status results: ",status.__len__()
    for x, vs in status:
      #print "STATUS: ",vs, " for ",x
      t = self.lookup(x)
      if t != None:
        t.status = vs
        # print "Set status.", t.status
      else:
        speclog("Couldn't lookup term: "+x)

    # Go back and see if we missed any properties defined in OWL. TODO: classes too. Or rewrite above SPARQL. addd more types for full query.
    q= 'SELECT ?x ?l ?c WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a ?type .  FILTER (?type = <http://www.w3.org/2002/07/owl#ObjectProperty>)}'
    q= 'SELECT distinct ?x ?l ?c WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a ?type . FILTER (?type = <http://www.w3.org/2002/07/owl#ObjectProperty> || ?type = <http://www.w3.org/2002/07/owl#DatatypeProperty> || ?type = <http://www.w3.org/1999/02/22-rdf-syntax-ns#Property> || ?type = <http://www.w3.org/2002/07/owl#FunctionalProperty> || ?type = <http://www.w3.org/2002/07/owl#InverseFunctionalProperty>) } '

    relations = g.query(q, initNs=bindings)
    for (term, label, comment) in relations:
        p = Property(str(term))
        got = self.lookup( str(term) )
        if got==None:
          # print "Made an OWL property! "+str(p.uri) 
          p.label = str(label)
          p.comment = str(comment)
          self.terms.append(p)
          if (not str(p) in tmpproperties): 
            tmpproperties.append(str(p))
            self.properties.append(p)

#    self.terms.sort()   # does this even do anything? 
#    self.classes.sort()
#    self.properties.sort()

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
    query = 'SELECT ?x ?l ?c WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c  } '
    relations = g.query(query, initNs=bindings)
    print "Properties and Classes (%d terms)" % len(relations) 
    print 40*"-"
    for (term, label, comment) in relations:
        print "term %s l: %s \t\tc: %s " % (term, label, comment)
    print

   # TODO: work out how to do ".encode('UTF-8')" here



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
      #print "Failed to niceName. Returning the whole thing."
      return(uri)   
    pref = rez.group(1)
    # print "...",self.ns_list.get(pref, pref),":",rez.group(2)
    # todo: make this work when uri doesn't match the regex --danbri
    # AttributeError: 'NoneType' object has no attribute 'group'
    return self.ns_list.get(pref, pref) + ":" + rez.group(2)


  # HTML stuff, should be a separate class

  def azlist(self):
    """Builds the A-Z list of terms"""
    c_ids = []
    p_ids = []
    for p in self.properties:
      p_ids.append(str(p.id))
    for c in self.classes:
      c_ids.append(str(c.id))
    c_ids.sort()
    p_ids.sort()
    return (c_ids, p_ids)



class VocabReport(object):

  def __init__(self, vocab, basedir='./examples/', temploc='template.html',templatedir='./examples/'):
    self.vocab = vocab
    self.basedir = basedir
    self.temploc = temploc
    self.templatedir = templatedir

    self._template = "no template loaded"

  # text.gsub(/<code>foaf:(\w+)<\/code>/){ defurl($1) } return "<code><a href=\"#term_#{term}\">foaf:#{term}</a></code>"
  def codelink(self, s):
    reg1 = re.compile(r"""<code>foaf:(\w+)<\/code>""")
    return(re.sub(reg1, r"""<code><a href="#term_\1">foaf:\1</a></code>""", s))	
  
  def _get_template(self):
        self._template = self.load_template() # should be conditional
        return self._template

  def _set_template(self, value):
    self._template = str(value)

  template = property(_get_template,_set_template)

  def load_template(self):
    filename = os.path.join(self.templatedir, self.temploc)

    f = open(filename, "r")
    template = f.read()
    return(template)

  def generate(self):
    tpl = self.template
    azlist = self.az()
    termlist = self.termlist()

    f = open ( self.vocab.filename, "r")
    rdfdata = f.read()
#   print "GENERATING >>>>>>>> "
## having the rdf in there was making it invalid
## removed in favour of RDFa
##    tpl = tpl % (azlist.encode("utf-8"), termlist.encode("utf-8"), rdfdata)
    tpl = tpl % (azlist.encode("utf-8"), azlist.encode("utf-8"), termlist.encode("utf-8"))
#    tpl = tpl % (azlist.encode("utf-8"), termlist.encode("utf-8"))
    return(tpl)

  def az(self):
    """AZ List for html doc"""
    c_ids, p_ids = self.vocab.azlist()
    az = """<div class="azlist">"""
    az = """%s\n<p>Classes: |""" % az
    # print c_ids, p_ids
    for c in c_ids:
        # speclog("Class "+c+" in az generation.")
        az = """%s <a href="#term_%s">%s</a> | """ % (az, str(c).replace(" ", ""), c)

    az = """%s\n</p>""" % az
    az = """%s\n<p>Properties: |""" % az
    for p in p_ids:
        # speclog("Property "+p+" in az generation.")
        az = """%s <a href="#term_%s">%s</a> | """ % (az, str(p).replace(" ", ""), p)
    az = """%s\n</p>""" % az
    az = """%s\n</div>""" % az
    return(az)

  def termlist(self):
    """Term List for html doc"""
    stableTxt = ''
    testingTxt = ''
    unstableTxt = ''
    archaicTxt = ''

    queries = ''
    c_ids, p_ids = self.vocab.azlist()
    tl = """<div class="termlist">"""
    tl = """%s<h3>Classes and Properties (full detail)</h3>\n<div class='termdetails'><br />\n\n""" % tl


# danbri hack 20100101 removed: href="http://www.w3.org/2003/06/sw-vocab-status/ns#%s" pending discussion w/ libby and leigh re URIs

    # first classes, then properties
    eg = """<div class="specterm" id="term_%s" about="%s" typeof="%s">
            <h3>%s: %s</h3> 
            <em>%s</em> - %s <br /><table style="th { float: top; }">
	    <tr><th>Status:</th>
	    <td><span rel="vs:status" >%s</span></td></tr>
            %s
            %s
            </table>
            %s
            <p style="float: right; font-size: small;">[<a href="#term_%s">#</a>] [<a href="http://wiki.foaf-project.org/w/term_%s">wiki</a>] <!-- %s --> [<a href="#glance">back to top</a>]</p>
            <br/>
            </div>""" 

# replace this if you want validation queries: xxx danbri
#            <p style="float: right; font-size: small;">[<a href="#term_%s">permalink</a>] [<a href="#queries_%s">validation queries</a>] [<a href="#glance">back to top</a>]</p>

    # todo, push this into an api call (c_ids currently setup by az above)

# classes
    for term in self.vocab.classes:
       # strings to use later
       domainsOfClass = '' 
       rangesOfClass = ''

#class in domain of
       g = self.vocab.graph

       q = 'SELECT ?d ?l WHERE {?d rdfs:domain <%s> . ?d rdfs:label ?l } ' % (term.uri)

       relations = g.query(q, initNs=bindings)
       startStr = '<tr><th>Properties include:</th>\n'

       contentStr = ''
       for (domain, label) in relations:
          dom = Term(domain)
# danbri hack 20100101
#          termStr = """<a href="#term_%s">%s</a>\n""" % (dom.id, label)
          termStr = """<a href="#term_%s">%s</a>\n""" % (dom.id, dom.id)
          contentStr = "%s %s" % (contentStr, termStr)

       if contentStr != "":
          domainsOfClass = "%s <td> %s </td></tr>" % (startStr, contentStr)


# class in range of
       q2 = 'SELECT ?d ?l WHERE {?d rdfs:range <%s> . ?d rdfs:label ?l } ' % (term.uri)
       relations2 = g.query(q2, initNs=bindings)
       startStr = '<tr><th>Used with:</th>\n'

       contentStr = ''
       for (range, label) in relations2:
          ran = Term(range)
#          termStr = """<a href="#term_%s">%s</a>\n""" % (ran.id, label)
# danbri hack 20100101 better to use exact IDs here
          termStr = """<a href="#term_%s">%s</a>\n""" % (ran.id, ran.id)
          contentStr = "%s %s" % (contentStr, termStr)

       if contentStr != "":
          rangesOfClass = "%s <td> %s</td></tr> " % (startStr, contentStr)


# class subclassof
       subClassOf = ''
 
       q = 'SELECT ?sc ?l WHERE {<%s> rdfs:subClassOf ?sc . ?sc rdfs:label ?l } ' % (term.uri)

       relations = g.query(q, initNs=bindings)
       startStr = '<tr><th>subClassOf</th>\n'

       contentStr = ''
       for (subclass, label) in relations:
          sub = Term(subclass)
          termStr = """<span rel="rdfs:subClassOf" href="%s"><a href="#term_%s">%s</a></span>\n""" % (subclass, sub.id, label) 
          contentStr = "%s %s" % (contentStr, termStr)

       if contentStr != "":
          subClassOf = "%s <td> %s </td></tr>" % (startStr, contentStr)

# class has subclass
       hasSubClass = ''
 
       q = 'SELECT ?sc ?l WHERE {?sc rdfs:subClassOf <%s>. ?sc rdfs:label ?l } ' % (term.uri)
       relations = g.query(q, initNs=bindings)
       startStr = '<tr><th>has subclass</th>\n'

       contentStr = ''
       for (subclass, label) in relations:
          sub = Term(subclass)
          termStr = """<a href="#term_%s">%s</a>\n""" % (sub.id, label)
          contentStr = "%s %s" % (contentStr, termStr)

       if contentStr != "":
          hasSubClass = "%s <td> %s </td></tr>" % (startStr, contentStr)

# is defined by

       classIsDefinedBy = ''
 
       q = 'SELECT ?idb WHERE { <%s> rdfs:isDefinedBy ?idb  } ' % (term.uri)
       relations = g.query(q, initNs=bindings)
       startStr	 = '\n'

       contentStr = ''
       for (isdefinedby) in relations:
          termStr = """<span rel="rdfs:isDefinedBy" href="%s" />\n""" % (isdefinedby)
          contentStr = "%s %s" % (contentStr, termStr)

       if contentStr != "":
          classIsDefinedBy = "%s <tr><td> %s </td></tr>" % (startStr, contentStr)

# disjoint with

       isDisjointWith = ''
 
       q = 'SELECT ?dj ?l WHERE { <%s> <http://www.w3.org/2002/07/owl#disjointWith> ?dj . ?dj rdfs:label ?l } ' % (term.uri)
       relations = g.query(q, initNs=bindings)
       startStr = '<tr><th>Disjoint With:</th>\n'

       contentStr = ''
       for (disjointWith, label) in relations:
          termStr = """<span rel="owl:disjointWith" href="%s"><a href="#term_%s">%s</a></span>\n""" % (disjointWith, label, label)
          contentStr = "%s %s" % (contentStr, termStr)

       if contentStr != "":
          isDisjointWith = "%s <td> %s </td></tr>" % (startStr, contentStr)

# end

       dn = os.path.join(self.basedir, "doc") 
       filename = os.path.join(dn, term.id+".en") 
       s = ''
       try:
         f = open ( filename, "r")
         s = f.read()
       except:
         s=''

       # if we want validation queries this is where it looks for them.
       filename = os.path.join(dn, term.id+".sparql") 
       fileStr = ''
       try:
         f = open ( filename, "r")
         fileStr = f.read()
         fileStr = "<h4><a name=\"queries_"+term.id+"\"></a>"+term.id+" Validation Query</h4><pre>"+cgi.escape(ss)+"</pre>"
       except:
         fileStr=''

       queries = queries +"\n"+ fileStr
       sn = self.vocab.niceName(term.uri)
       s = termlink(s)

	# danbri added another term.id 20010101 and removed term.status
       zz = eg % (term.id,term.uri,"rdfs:Class","Class", sn, term.label, term.comment, term.status,domainsOfClass,rangesOfClass+subClassOf+hasSubClass+classIsDefinedBy+isDisjointWith, s,term.id, term.id, term.id)

## we add to the relevant string - stable, unstable, testing or archaic
       if(term.status == "stable"):
          stableTxt = stableTxt + zz
       if(term.status == "testing"):
          testingTxt = testingTxt + zz
       if(term.status == "unstable"):
          unstableTxt = unstableTxt + zz
       if(term.status == "archaic"):
          archaicTxt = archaicTxt + zz

## then add the whole thing to the main tl string

    tl = tl+"<h2>Classes</h2>\n"
    tl = "%s %s" % (tl, stableTxt+"\n"+testingTxt+"\n"+unstableTxt+"\n"+archaicTxt)
    tl = tl+"<h2>Properties</h2>\n"

# properties

    stableTxt = ''
    testingTxt = ''
    unstableTxt = ''
    archaicTxt = ''

    for term in self.vocab.properties:
       domainsOfProperty = ''
       rangesOfProperty = ''

# domain of properties
       g = self.vocab.graph
       q = 'SELECT ?d ?l WHERE {<%s> rdfs:domain ?d . ?d rdfs:label ?l } ' % (term.uri)
       relations = g.query(q, initNs=bindings)
       startStr = '<tr><th>Domain:</th>\n'

       contentStr = ''
       for (domain, label) in relations:
          dom = Term(domain)
          termStr = """<span rel="rdfs:domain" href="%s"><a href="#term_%s">%s</a></span>\n""" % (domain, dom.id, label)
          contentStr = "%s %s" % (contentStr, termStr)

       if contentStr != "":
          domainsOfProperty = "%s <td>%s</td></tr>" % (startStr, contentStr)


# range of properties
       q2 = 'SELECT ?d ?l WHERE {<%s> rdfs:range ?d . ?d rdfs:label ?l } ' % (term.uri)
       relations2 = g.query(q2, initNs=bindings)
       startStr = '<tr><th>Range:</th>\n'
       contentStr = ''
       for (range, label) in relations2:
          ran = Term(range)
          termStr = """<span rel="rdfs:range" href="%s"><a href="#term_%s">%s</a></span>\n""" % (range, ran.id, label)
          contentStr = "%s %s" % (contentStr, termStr)

       if contentStr != "":
          rangesOfProperty = "%s <td>%s</td>	</tr>" % (startStr, contentStr)


# is defined by

       propertyIsDefinedBy = ''
 
       q = 'SELECT ?idb WHERE { <%s> rdfs:isDefinedBy ?idb  } ' % (term.uri)
       relations = g.query(q, initNs=bindings)
       startStr = '\n'

       contentStr = ''
       for (isdefinedby) in relations:
          termStr = """<span rel="rdfs:isDefinedBy" href="%s" />\n""" % (isdefinedby)
          contentStr = "%s %s" % (contentStr, termStr)

       if contentStr != "":
          propertyIsDefinedBy = "%s <tr><td> %s </td></tr>" % (startStr, contentStr)


# inverse functional property

       ifp = ''
 
       q = 'SELECT * WHERE { <%s> rdf:type <http://www.w3.org/2002/07/owl#InverseFunctionalProperty> } ' % (term.uri)
       relations = g.query(q, initNs=bindings)
       startStr = '<tr><th colspan="2">Inverse Functional Property</th>\n'

       if (len(relations) > 0):
          termStr = """<span rel="rdf:type" href="http://www.w3.org/2002/07/owl#InverseFunctionalProperty"></span>"""
          ifp = "%s <td> %s </td></tr>" % (startStr, termStr)

# functonal property

       fp = ''
 
       q = 'SELECT * WHERE { <%s> rdf:type <http://www.w3.org/2002/07/owl#FunctionalProperty> } ' % (term.uri)
       relations = g.query(q, initNs=bindings)
       startStr = '<tr><th colspan="2">Functional Property</th>\n'

       if (len(relations) > 0):
          termStr = """<span rel="rdf:type" href="http://www.w3.org/2002/07/owl#FunctionalProperty"></span>"""
          fp = "%s <td> %s </td></tr>" % (startStr, termStr)

# end

       dn = os.path.join(self.basedir, "doc") 
       filename = os.path.join(dn, term.id+".en") 

       s = ''
       try:
         f = open ( filename, "r")
         s = f.read()
       except:
         s=''

       sn = self.vocab.niceName(term.uri)
       s = termlink(s)
       
	# danbri added another term.id 20010101
       zz = eg % (term.id, term.uri,"rdf:Property","Property", sn, term.label, term.comment, term.status,term.status,domainsOfProperty,rangesOfProperty+propertyIsDefinedBy+ifp+fp, s,term.id, term.id, term.id)

## we add to the relevant string - stable, unstable, testing or archaic
       if(term.status == "stable"):
          stableTxt = stableTxt + zz
       if(term.status == "testing"):
          testingTxt = testingTxt + zz
       if(term.status == "unstable"):
          unstableTxt = unstableTxt + zz
       if(term.status == "archaic"):
          archaicTxt = archaicTxt + zz

## then add the whole thing to the main tl string

    tl = "%s %s" % (tl, stableTxt+"\n"+testingTxt+"\n"+unstableTxt+"\n"+archaicTxt)


##    tl = "%s %s" % (tl, zz)

    ## ensure termlist tag is closed
    return(tl+"\n"+queries+"</div>\n</div>")


  def rdfa(self):

    return( "<html>rdfa here</html>")


  def htmlDocInfo( t, termdir='../docs' ):
    """Opens a file based on the term name (t) and termdir (defaults to
    current directory. Reads in the file, and returns a linkified
    version of it."""
    if termdir==None:
      termdir=self.basedir

    doc = ""
    try:
        f = open("%s/%s.en" % (termdir, t), "r")
        doc = f.read()
        doc = termlink(doc)
    except: 
        return "<p>No detailed documentation for this term.</p>"
    return doc

  # report what we've parsed from our various sources
  def report(self):
    s = "Report for vocabulary from " + self.vocab.filename + "\n"
    if self.vocab.uri != None:
      s += "URI: " + self.vocab.uri + "\n\n"
    for t in self.vocab.uterms:
      print "TERM as string: ",t
      s += t.simple_report()
    return s
 
