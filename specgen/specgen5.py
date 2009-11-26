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



import libvocab
from libvocab import Vocab, VocabReport
from libvocab import Term
from libvocab import Class
from libvocab import Property
import sys
import os.path
import getopt


# Make a spec
def makeSpec(dir, uri, shortName):
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
  print "Usage:",sys.argv[0],"--indir=dir --ns=uri --prefix=prefix"
  print "e.g. "
  print sys.argv[0], "./specgen5.py --indir=examples/foaf/ --ns=http://xmlns.com/foaf/0.1/ --prefix=foaf"


def main():
  ##looking for outdir, outfile, indir, namespace, shortns

  try:
        opts, args = getopt.getopt(sys.argv[1:], None, ["outdir=", "outfile=", "indir=", "ns=", "prefix="])
        # print opts
  except getopt.GetoptError, err:
        # print help information and exit:
        print str(err) # will print something like "option -a not recognized"
        usage()
        sys.exit(2)

  indir = None #indir
  uri = None #ns
  shortName = None #prefix
  outdir = None 
  outfile = None


  if len(opts) ==0:
      usage()
      sys.exit(2)   
  

  for o, a in opts:
      if o == "--indir":
            indir = a
      elif o == "--ns":
            uri = a
      elif o == "--prefix":
            shortName = a
      elif o == "--outdir":
            outdir = a
      elif o == "--outfile":
            outfile = a

#first check all the essentials are there

  # check we have been given a indir
  if indir == None or len(indir) ==0:
      print "No in directory given"
      usage()
      sys.exit(2)   

  # check we have been given a namespace url
  if (uri == None or len(uri)==0):
      print "No namespace uri given"
      usage()
      sys.exit(2)   

  # check we have a prefix
  if (shortName == None or len(shortName)==0):
      print "No prefix given"
      usage()
      sys.exit(2)   

  # check outdir
  if (outdir == None or len(outdir)==0):
      outdir = indir
      print "No outdir, using indir ",indir
  
  if (outfile == None or len(outfile)==0):
      outfile = "_tmp_spec.html"
      print "No outfile, using ",outfile

# now do some more checking
  # check indir is a dir and it is readable and writeable
  if (os.path.isdir(indir)):
      print "In directory is ok ",indir
  else:
      print indir,"is not a directory"
      usage()
      sys.exit(2)   

  # check outdir is a dir and it is readable and writeable
  if (os.path.isdir(outdir)):
      print "Out directory is ok ",outdir
  else:
      print outdir,"is not a directory"
      usage()
      sys.exit(2)   

  #check we can read infile    
  try:
    filename = os.path.join(indir, "index.rdf")
    f = open(filename, "r")
  except:
    print "Can't open index.rdf in",indir
    usage()
    sys.exit(2)   

  #look for the template file
  try:
    filename = os.path.join(indir, "template.html")
    f = open(filename, "r")
  except:
    print "No template.html in ",indir
    usage()
    sys.exit(2)   

  # check we can write to outfile
  try:
    filename = os.path.join(outdir, outfile)
    f = open(filename, "w")
  except:
    print "Cannot write to ",outfile," in",outdir
    usage()
    sys.exit(2)   

  makeSpec(indir,uri,shortName)
  

if __name__ == "__main__":
    main()

