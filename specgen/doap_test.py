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

# Test FOAF spec

fn = 'examples/doap/doap.rdf'
spec = Vocab( fn )

# spec = Vocab( DOAP )

spec.uri = DOAP
# spec.raw()
spec.index() # slurp info from sources
# print spec.report()

for p in spec.properties:
  print "Got a property: " + p
  print p.simple_report()
for c in spec.classes:
  print "Got a class: " + c
  print c.simple_report()
