#!/usr/bin/env python

__all__ = [ 'main' ]



# Quick script to see if this stuff works on another schema: SIOC.
# danbri@danbri.org

# currently: seems to partially load but shows nothing

import libvocab
from libvocab import Vocab
from libvocab import Term
from libvocab import Class
from libvocab import Property

from libvocab import SIOC

# Test SIOC spec

fn = 'examples/sioc/sioc.rdf'

spec = Vocab( fn )

# spec = Vocab( DOAP )

spec.uri = SIOC

# spec.raw()
spec.index() # slurp info from sources
print spec.report()

for p in spec.properties:
  print "Got a property: " + p
  print p.simple_report()
for c in spec.classes:
  print "Got a class: " + c
  print c.simple_report()
