#!/usr/bin/env python

__all__ = [ 'main' ]



# Quick script to see if this stuff works on another schema: DOAP's.
# For now, we find problems with accents ...'Versi\xf3n' vs 'Version'
# danbri@danbri.org

import libvocab
from libvocab import Vocab
from libvocab import Term
from libvocab import Class
from libvocab import Property

from libvocab import DOAP

# Test DOAP spec

fn = 'examples/doap/doap-en.rdf' 

# fn = 'examples/doap/doap.rdf' 

spec = Vocab( fn )

# Note: I separated out a doap-en since libvocab makes assumptions of 'en'
# this avoids combinatorial explosion of spanish/french/eng labels vs comments
# TODO: don't assume the main index.rdf is monolingual (whether 'en' or other)

# spec = Vocab( DOAP )

spec.uri = DOAP
spec.raw()
spec.index() # slurp info from sources
# print spec.report()

for p in spec.properties:
  print "Got a property: " + p
  print p.simple_report().encode('UTF-8')
for c in spec.classes:
  print "Got a class: " + c
  print c.simple_report().encode('UTF-8')
