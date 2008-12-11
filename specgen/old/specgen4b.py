#!/usr/bin/env  python2.5


#
# SpecGen code adapted to be independent of a particular vocabulary (e.g., FOAF)
# <http://sw.deri.org/svn/sw/2005/08/sioc/ontology/spec/specgen4.py>
# 
# This software is licensed under the terms of the MIT License.
#
# Copyright 2008 Uldis Bojars <captsolo@gmail.com>
# Copyright 2008 Christopher Schmidt
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

__all__ = [ 'main' ]
 
import sys, time, re, urllib, getopt

import logging

# Configure how we want rdflib logger to log messages
_logger = logging.getLogger("rdflib")
_logger.setLevel(logging.DEBUG)
_hdlr = logging.StreamHandler()
_hdlr.setFormatter(logging.Formatter('%(name)s %(levelname)s: %(message)s'))
_logger.addHandler(_hdlr)

from rdflib.Graph import ConjunctiveGraph as Graph
from rdflib import plugin
from rdflib.store import Store
from rdflib import Namespace
from rdflib import Literal
from rdflib import URIRef

from rdflib.sparql.bison import Parse
store = Graph()

# with some care this could be made less redundant
store.bind("dc", "http://http://purl.org/dc/elements/1.1/")
store.bind("foaf", "http://xmlns.com/foaf/0.1/")
store.bind("dc", 'http://purl.org/dc/elements/1.1/')
store.bind("rdf", 'http://www.w3.org/1999/02/22-rdf-syntax-ns#')
store.bind("rdfs", 'http://www.w3.org/2000/01/rdf-schema#')
store.bind("owl", 'http://www.w3.org/2002/07/owl#') 
store.bind("vs", 'http://www.w3.org/2003/06/sw-vocab-status/ns#')

# Create a namespace object for the Friend of a friend namespace.
foaf = Namespace("http://xmlns.com/foaf/0.1/")
dc = Namespace('http://purl.org/dc/elements/1.1/')
rdf = Namespace('http://www.w3.org/1999/02/22-rdf-syntax-ns#')
rdfs = Namespace('http://www.w3.org/2000/01/rdf-schema#')
owl = Namespace('http://www.w3.org/2002/07/owl#')
vs = Namespace('http://www.w3.org/2003/06/sw-vocab-status/ns#')

# add your namespaces here

classranges = {}
classdomains = {}

termdir = '../doc' # .. for FOAF

# namespace for which the spec is being generated. 
spec_url = "http://xmlns.com/foaf/0.1/"
spec_pre = "foaf"
# spec_url = "http://rdfs.org/sioc/ns#"
# spec_pre = "sioc"

spec_ns = Namespace(spec_url)

ns_list = { "http://xmlns.com/foaf/0.1/" : "foaf", 
            'http://purl.org/dc/elements/1.1/' : "dc",
            'http://purl.org/dc/terms/' : "dcterms",
            'http://usefulinc.com/ns/doap#' : 'doap',
	    'http://www.w3.org/1999/02/22-rdf-syntax-ns#' : "rdf",
	    'http://www.w3.org/2000/01/rdf-schema#' : "rdfs",
	    'http://www.w3.org/2002/07/owl#' : "owl",
            'http://www.w3.org/2001/XMLSchema#' : 'xsd',
  	    'http://www.w3.org/2003/06/sw-vocab-status/ns#' : "status",
	    'http://purl.org/rss/1.0/modules/content/' : "content",
	    'http://rdfs.org/sioc/ns#' : "sioc" }

def niceName( uri = None ):
   if uri is None:
      return
   speclog("Nicing uri "+uri)
   regexp = re.compile( "^(.*[/#])([^/#]+)$" )

   rez = regexp.search( uri )
#   return uri # temporary skip this whole thing!
  
   pref = rez.group(1)
    # todo: make this work when uri doesn't match the regex --danbri
   # AttributeError: 'NoneType' object has no attribute 'group'

   return ns_list.get(pref, pref) + ":" + rez.group(2)

def setTermDir(directory):
    global termdir
    termdir = directory

def termlink(string):
    """FOAF specific: function which replaces <code>foaf:*</code> with a 
    link to the term in the document."""
    return re.sub(r"<code>" + spec_pre + r":(\w+)</code>", r"""<code><a href="#term_\1">""" + spec_pre + r""":\1</a></code>""", string)    

def return_name(m, urinode):
    "Trims the FOAF namespace out of a term to give a name to the term."
    return str(urinode).replace(spec_url, "")

def get_rdfs(m, urinode):
    "Returns label and comment given an RDF.Node with a URI in it"

    comment = ''
    label = ''
    r = wrap_find_statements(m, urinode, rdfs.label, None)
    try:
      l = r.next()
      label = l[2] #l['todo-labels' # l[0][2] # .current().object.literal_value['string']
    except StopIteration:
      ''

    r = wrap_find_statements(m, urinode, rdfs.comment, None)
    try:
      c = r.next()
      comment = c[2] # c[2] #.current().object.literal_value['string']
    except StopIteration:
      ''

    return label, comment

def get_status(m, urinode):
    "Returns the status text for a term."
    status = ''
    r = wrap_find_statements(m, urinode, vs.term_status, None)
    try:
      s = r.next()
      status = s[2]
    except StopIteration:
      ''
    return(status)

def htmlDocInfo( t ):
    """Opens a file based on the term name (t) and termdir directory (global).
       Reads in the file, and returns a linkified version of it."""
    doc = ""
    try:
        f = open("%s/%s.en" % (termdir, t), "r")
        doc = f.read()
        doc = termlink(doc)
    except:
        speclog("Failed to open file for more info on "+t+ " termdir: " +termdir)
        return "" 	# "<p>No detailed documentation for this term.</p>"
    return doc

def owlVersionInfo(m):
    r = wrap_find_statements(m, None, owl.versionInfo, None)
    try:
      v = r.next()
      return(v[2]) 
    except StopIteration:
      ''

def rdfsPropertyInfo(term,m):
    """Generate HTML for properties: Domain, range, status."""
    doc = ""
    range = ""
    domain = ""

    # Find subPropertyOf information
    speclog("Finding subPropertyOf info: skipping.")
    # todo: implement in sparql instead.
#    r = wrap_find_statements(m, term, rdfs.subPropertyOf, None )
#    try:
#      o = r.next()
#      doc += "\t<tr><th>sub-property-of:</th>"
#      rlist = ''
#      for st in o:
#        speclog("XXX superProperty: "+st)
#        k = st[2] 
#        if (spec_url in k):
#          k = """<a href="#term_%s">%s</a>""" % (k.replace(spec_url, ""), niceName(k))
#        else:
#          k = """<a href="%s">%s</a>""" % (k, niceName('xxxzzz'+k))
#          rlist += "%s " % k
#          doc += "\n\t<td>%s</td></tr>\n" % rlist
#    except StopIteration:
#      ''

    # domain and range stuff (properties only)
    r = wrap_find_statements(m, term, rdfs.domain, None)
    try:
      d = r.next()
      domain = d[2]
    except StopIteration:
        ""

    r = wrap_find_statements(m, term, rdfs.range, None)
    try:
      rr = r.next()
      range = rr[2]
    except StopIteration:
      ''

    speclog("range: "+range+ "domain: "+domain)
    

    if domain:
        # NOTE can add a warning of multiple rdfs domains / ranges
        if (spec_url in domain):
            domain = """<a href="#term_%s">%s</a>""" % (domain.replace(spec_url, ""), niceName(domain))
        else:
            domain = """<a href="%s">%s</a>""" % (domain, niceName(domain))
        doc += "\t<tr><th>Domain:</th>\n\t<td>%s</td></tr>\n" % domain
    
    if range:
        if (spec_url in range):
            range = """<a href="#term_%s">%s</a>""" % (range.replace(spec_url, ""), niceName(range))
        else:
            range = """<a href="%s">%s</a>""" % (range, niceName(range))
        doc += "\t<tr><th>Range:</th>\n\t<td>%s</td></tr>\n" % range
    return doc

def rdfsClassInfo(term,m):
    """Generate rdfs-type information for Classes: ranges, and domains."""
    global classranges
    global classdomains
    doc = ""

    # Find subClassOf information

    o = wrap_find_statements(m, term, rdfs.subClassOf, None )
    if o:
        doc += "\t<tr><th>sub-class-of:</th>"
	rlist = ''
	
        for st in o:
	    k = str( st[2] )
            if (spec_url in k):
                k = """<a href="#term_%s">%s</a>""" % (k.replace(spec_url, ""), niceName(k))
            else:
                k = """<a href="%s">%s</a>""" % (k, niceName(k))
	    rlist += "%s " % k
        doc += "\n\t<td>%s</td></tr>\n" % rlist

    # Find out about properties which have rdfs:range of t
    r = classranges.get(term, "")
    if r:
      rlist = ''
      for k in r:
        if (spec_url in k):
            k = """<a href="#term_%s">%s</a>""" % (k.replace(spec_url, ""), niceName(k))
        else:
            k = """<a href="%s">%s</a>""" % (k, niceName(k))
        rlist += "%s " % k
      doc += "<tr><th>in-range-of:</th><td>"+rlist+"</td></tr>"
    
    # Find out about properties which have rdfs:domain of t
    d = classdomains.get(str(term), "")
    if d:
      dlist = ''
      for k in d:
        if (spec_url in k):
            k = """<a href="#term_%s">%s</a>""" % (k.replace(spec_url, ""), niceName(k))
        else:
            k = """<a href="%s">%s</a>""" % (k, niceName(k))
        dlist += "%s " % k
      doc += "<tr><th>in-domain-of:</th><td>"+dlist+"</td></tr>"

    return doc

def owlInfo(term,m):
    """Returns an extra information that is defined about a term (an RDF.Node()) using OWL."""
    res = ''
    
    # Inverse properties ( owl:inverseOf )
#    r = wrap_find_statements(m,term, owl.inverseOf, None)
#    try:
#      o = r.next()
#      res += "\t<tr><th>Inverse:</th>"
#      rlist = ''
#      for st in o:
#        k = str( st[2] )
#        if (spec_url in k):
#          k = """<a href="#term_%s">%s</a>""" % (k.replace(spec_url, ""), niceName(k))
#        else:
#          k = """<a href="%s">%s</a>""" % (k, niceName(k))
#        rlist += "%s " % k
#        res += "\n\t<td>%s</td></tr>\n" % rlist
#    except StopIteration:
#      print ''

    # Datatype Property ( owl.DatatypeProperty )
    r = wrap_find_statements( m, term, rdf.type, owl.DatatypeProperty) 
    try:
      o = r.next()
      res += "\t<tr><th>OWL Type:</th>\n\t<td>DatatypeProperty</td></tr>\n"
    except StopIteration:
      #print ''
      ''
      #

    # Object Property ( owl.ObjectProperty )
    r = wrap_find_statements(m, term, rdf.type, owl.ObjectProperty) 
    try: 
      o = r.next()
      res += "\t<tr><th>OWL Type:</th>\n\t<td>ObjectProperty</td></tr>\n"
    except StopIteration:
      ''

    # IFPs ( owl.InverseFunctionalProperty )
    r = wrap_find_statements(m, term, rdf.type, owl.InverseFunctionalProperty) 
    try:
      o = r.next()
      res += "\t<tr><th>OWL Type:</th>\n\t<td>InverseFunctionalProperty (uniquely identifying property)</td></tr>\n"
    except StopIteration:
       ''

    # Symmetric Property ( owl.SymmetricProperty )
    r = wrap_find_statements(m, term, rdf.type, owl.SymmetricProperty) 
    try:
      o = r.next()
      res += "\t<tr><th>OWL Type:</th>\n\t<td>SymmetricProperty</td></tr>\n"
    except StopIteration:
      ''
    return res

def docTerms(category, list, m):
    """A wrapper class for listing all the terms in a specific class (either
    Properties, or Classes. Category is 'Property' or 'Class', list is a 
    list of term names (strings), return value is a chunk of HTML."""
    doc = ""
    nspre = spec_pre
    for t in list:
        term = spec_ns[t]
        doc += """<div class="specterm" id="term_%s">\n<h3>%s: %s:%s</h3>\n""" % (t, category, nspre, t)
        label, comment = get_rdfs(m, term)    
        status = get_status(m, term)
        doc += "<p><em>%s</em> - %s <br /></p>" % (label, comment)
        doc += """<table>\n"""
        doc += owlInfo(term,m)
        if category=='Property': doc += rdfsPropertyInfo(term,m)
        if category=='Class': doc += rdfsClassInfo(term,m)
        doc += "</table>\n"
        doc += htmlDocInfo(t)
        doc += "<p class=\"backtotop\">[<a href=\"#sec-glance\">back to top</a>]</p>\n\n"
        doc += "\n<br/>\n</div>\n\n"
    return doc

def buildazlist(classlist, proplist):
    """Builds the A-Z list of terms. Args are a list of classes (strings) and 
    a list of props (strings)"""
    azlist = """<div class="azlist">"""
    azlist = """%s\n<p>Classes: |""" % azlist
    classlist.sort()
    for c in classlist:
        speclog("Class "+c+" in azlist generation.")
        azlist = """%s <a href="#term_%s">%s</a> | """ % (azlist, c.replace(" ", ""), c)

    azlist = """%s\n</p>""" % azlist
    azlist = """%s\n<p>Properties: |""" % azlist
   
    proplist.sort()
    for p in proplist:
        speclog("Property "+p+" in azlist generation.")
        azlist = """%s <a href="#term_%s">%s</a> | """ % (azlist, p.replace(" ", ""), p)
    azlist = """%s\n</p>""" % azlist
    azlist = """%s\n</div>""" % azlist

    return azlist

def build_simple_list(classlist, proplist):
    """Builds a simple <ul> A-Z list of terms. Args are a list of classes (strings) and 
    a list of props (strings)"""

    azlist = """<div style="padding: 5px; border: dotted; background-color: #ddd;">"""
    azlist = """%s\n<p>Classes:""" % azlist
    azlist += """\n<ul>"""

    classlist.sort()
    for c in classlist:
        azlist += """\n  <li><a href="#term_%s">%s</a></li>""" % (c.replace(" ", ""), c)
    azlist = """%s\n</ul></p>""" % azlist

    azlist = """%s\n<p>Properties:""" % azlist
    azlist += """\n<ul>"""
    proplist.sort()
    for p in proplist:
        azlist += """\n  <li><a href="#term_%s">%s</a></li>""" % (p.replace(" ", ""), p)
    azlist = """%s\n</ul></p>""" % azlist

    azlist = """%s\n</div>""" % azlist
    return azlist

def specInformation(m):
    """Read through the spec (provided as a Redland model) and return classlist
    and proplist. Global variables classranges and classdomains are also filled
    as appropriate."""
    global classranges
    global classdomains

    # Find the class information: Ranges, domains, and list of all names.
    classlist = []
# xxxx
   # See http://chatlogs.planetrdf.com/swig/2008-12-10#T14-23-48
   # todo: rewrite using SPARQL? set up some tests first.
   # todo: make it optional whether we skip deprecated terms

    print "spec_url is ", spec_url
    for classStatement in  wrap_find_statements(m, None, rdf.type, rdfs.Class):
        speclog("OK we got an rdfs class statement. sub is:"+classStatement[0])
        if classStatement[0].startswith(spec_url) :
            # print "It starts with spec_url!"
            for range in wrap_find_statements(m, None, rdfs.range, classStatement[0]):
                if not wrap_matches(m, range[0], rdf.type, owl.DeprecatedProperty ):
                    classranges.setdefault(classStatement[0], []).append(str(range[0]))
            for domain in wrap_find_statements(m, None, rdfs.domain, classStatement[0]):
                if not wrap_matches(m, domain[0], rdf.type, owl.DeprecatedProperty):
                    classdomains.setdefault(str(classStatement[0]), []).append(str(domain[0]))
            classlist.append(return_name(m, classStatement[0]))

    # Why deal with OWL separately?
    for classStatement in  wrap_find_statements(m, None, rdf.type, owl.Class):
        speclog("OK we got an owl class statement. sub is:"+ classStatement[0])
        if str(classStatement[0]).startswith(spec_url) :
            for range in wrap_find_statements(m, None, rdfs.range, classStatement[0]):
                if not wrap_matches(m, range[0], rdf.type, owl.DeprecatedProperty ):
                    if str(range[0]) not in classranges.get( str(classStatement[0]), [] ) :
                        classranges.setdefault(str(classStatement[0]), []).append(str(range[0]))
            for domain in wrap_find_statements(m, None, rdfs.domain, classStatement[0]):
                if not wrap_matches(m, domain[0], rdf.type, owl.DeprecatedProperty ):
                    if str(domain[0]) not in classdomains.get( str(classStatement[0]), [] ) :
                        classdomains.setdefault(str(classStatement[0]), []).append(str(domain[0]))
            if return_name(m, classStatement[0]) not in classlist:
                classlist.append(return_name(m, classStatement[0]))

    # Create a list of properties in the schema.
    proplist = []
    for propertyStatement in  wrap_find_statements(m, None, rdf.type, rdf.Property):
        speclog("OK we got a property statement: "+ propertyStatement[0])
        speclog("asking s: "+propertyStatement[0]+ " p: " + rdf.type + " o: " + owl.DeprecatedProperty)
        if not (wrap_find_statements(m, propertyStatement[0], rdf.type, owl.DeprecatedProperty )):
            speclog(" and OK, not deprecated. "+ propertyStatement[0])
            if propertyStatement[0].startswith(spec_url):
               speclog("property uri "+propertyStatement[0]+" matches spec_url") 
               proplist.append(return_name(m, propertyStatement[0]))
    for propertyStatement in  wrap_find_statements(m, None, rdf.type, owl.DatatypeProperty):
        if not wrap_matches(m, propertyStatement[0], rdf.type, owl.DeprecatedProperty ):
            if propertyStatement[0].startswith(spec_url) :
                if return_name(m, propertyStatement[0]) not in proplist:
                    proplist.append(return_name(m, propertyStatement[0]))
    for propertyStatement in  wrap_find_statements(m, None, rdf.type, owl.ObjectProperty):
        if not wrap_matches(m, propertyStatement[0], rdf.type, owl.DeprecatedProperty ):
            if propertyStatement[0].startswith(spec_url) :
                if return_name(m, propertyStatement[0]) not in proplist:
                    proplist.append(return_name(m, propertyStatement[0]))
    for propertyStatement in  wrap_find_statements(m, None, rdf.type, owl.SymmetricProperty):
        if not wrap_matches(m, propertyStatement[0], rdf.type, owl.DeprecatedProperty ):
            if propertyStatement[0].startswith(spec_url) :
                if return_name(m, propertyStatement[0]) not in proplist:
                    proplist.append(return_name(m, propertyStatement[0]))

    return classlist, proplist
    
def main(specloc, template, mode="spec"):
    """The meat and potatoes: Everything starts here."""

    m = Graph()
    m.parse(specloc)

#    m = RDF.Model()
#    p = RDF.Parser()
#    p.parse_into_model(m, specloc)
    
    classlist, proplist = specInformation(m)
    
    if mode == "spec":
        # Build HTML list of terms.
        azlist = buildazlist(classlist, proplist)
    elif mode == "list":
        # Build simple <ul> list of terms.
        azlist = build_simple_list(classlist, proplist)

    # Generate Term HTML
#    termlist = "<h3>Classes and Properties (full detail)</h3>"
    termlist = docTerms('Class',classlist,m)
    termlist += docTerms('Property',proplist,m)
    
    # Generate RDF from original namespace.
    u = urllib.urlopen(specloc)
    rdfdata = u.read()
    rdfdata = re.sub(r"(<\?xml version.*\?>)", "", rdfdata)
    rdfdata = re.sub(r"(<!DOCTYPE[^]]*]>)", "", rdfdata)
    rdfdata.replace("""<?xml version="1.0"?>""", "")
    
    # print template % (azlist.encode("utf-8"), termlist.encode("utf-8"), rdfdata.encode("ISO-8859-1"))
    #template = re.sub(r"^#format \w*\n", "", template)
    #template = re.sub(r"\$VersionInfo\$", owlVersionInfo(m).encode("utf-8"), template) 
    
    # NOTE: This works with the assumtpion that all "%" in the template are escaped to "%%" and it
    #       contains the same number of "%s" as the number of parameters in % ( ...parameters here... )

    print "AZlist",azlist
    print "Termlist",termlist
 
#xxx    template = template % (azlist.encode("utf-8"), termlist.encode("utf-8"));    
#    template += "<!-- specification regenerated at " + time.strftime('%X %x %Z') + " -->"
    
    return template


def speclog(str):
  sys.stderr.write("LOG: "+str+"\n")

# utility to help wrap redland idioms
def wrap_find_statements(m,s,p,o):
    subject=s 
    if not s: 
      subject='NIL'

    predicate = p
    if not p: 
      predicate='NIL'

    object = o 
    if not o: 
      object='NIL'

    speclog("Q: " + subject + " / " + predicate + " / " + object+"\n") 
    return(m.triples((s,p,o)))

def wrap_matches(m,s,p,o):
      r = m.triples((s,p,o))
      a = False
      try:
        r.next()
        a = True
        speclog("found it") 
        return(a)
      except StopIteration:
        ''

def usage():
    print "Usage: "
    print "  No information yet !!!"

if __name__ == "__main__":
    """Specification generator tool, used for FOAF & SIOC ontology maintenance."""
    
    specloc = "file:index.rdf"
    temploc = "template.html"
    mode = "spec"

    try:
        optlist, args = getopt.getopt( sys.argv[1:], "l" )
    except getopt.GetoptError:
        usage()
        sys.exit()
    
    if (len(args) >= 2):
        temploc = args[1]
    if (len(args) >= 1):
        specloc = args[0]

    for o,v in optlist:
        if o == "-l":
            mode = "list"

    # template is a template file for the spec, python-style % escapes
    # for replaced sections.
    f = open(temploc, "r")
    template = f.read()

    print main(specloc, template, mode)

