#!/usr/bin/env python

# This is a draft rewrite of specgen, the family of scripts (originally
# in Ruby, then Python) that are used with the FOAF and SIOC RDF vocabularies.
# This version is a rewrite by danbri, begun after a conversion of 
# Uldis Bojars and Christopher Schmidt's specgen4.py to use rdflib instead of
# Redland's Python bindings. While it shares their goal of being independent
# of any particular RDF vocabulary, this first version's main purpose is 
# to get the FOAF spec workflow moving again. It doesn't work yet.
# 
# A much more literal conversion of specgen4.py to use rdflib can be 
# found, abandoned, in the old/ directory as 'specgen4b.py'.
#
# 	Copyright 2008 Dan Brickley <http://danbri.org/>
#
# ...and probably includes bits of code that are:
#
# 	Copyright 2008 Uldis Bojars <captsolo@gmail.com>
# 	Copyright 2008 Christopher Schmidt
#
# This software is licensed under the terms of the MIT License.
#
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

import libvocab
from libvocab import Vocab, VocabReport
from libvocab import Term
from libvocab import Class
from libvocab import Property
import sys
import os.path


# Make a spec
def makeSpec(dir, uri):
  spec = Vocab( dir, 'index.rdf')
  spec.uri = uri
  spec.addShortName(shortName)
#  spec.shortName = shortName
  spec.index() # slurp info from sources

  out = VocabReport( spec, dir ) 
# print spec.unique_terms()
# print out.generate()

  filename = os.path.join(dir, "_tmp_spec.html")
  print "Printing to ",filename

  f = open(filename,"w")
  result = out.generate()
  f.write(result)

# Make FOAF spec
def makeFoaf():
  makeSpec("examples/foaf/","http://xmlns.com/foaf/0.1/")

# Spare stuff
#spec.raw()
#print spec.report().encode('UTF-8')

#for p in spec.properties:
#  print "Got a property: " + p
#  print p.simple_report().encode('UTF-8')
#for c in spec.classes:
#  print "Got a class: " + c
#  print c.simple_report().encode('UTF-8')
#
#print spec.generate()



def usage():
  print "Usage:",sys.argv[0],"dir uri shortName"
  print "e.g. "
  print sys.argv[0], "examples/foaf/ http://xmlns.com/foaf/0.1/ foaf"

if len(sys.argv) < 4:
  usage()
  sys.exit(2)   
else:
  # check it is a dir and it is readable and writeable
  dir = sys.argv[1]
  uri = sys.argv[2]
  shortName = sys.argv[3]

  if (os.path.isdir(dir)):
    print "ok"
  else:
    print dir,"is not a directory"
    usage()
    sys.exit(2)   
    
  try:
    filename = os.path.join(dir, "index.rdf")
    f = open(filename, "r")
  except:
    print "Can't open index.rdf in",dir
    usage()
    sys.exit(2)   

  try:
    filename = os.path.join(dir, "template.html")
    f = open(filename, "r")
  except:
    print "No template.html in",dir
    usage()
    sys.exit(2)   

  try:
    filename = os.path.join(dir, "_tmp_spec.html")
    f = open(filename, "w")
  except:
    print "Cannot write to _tmp_spec.html in",dir
    usage()
    sys.exit(2)   

  makeSpec(dir,uri)
  

