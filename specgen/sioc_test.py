#!/usr/bin/env python

__all__ = [ 'main' ]



# Quick script to see if this stuff works on another schema: SIOC.
# danbri@danbri.org

# currently: seems to partially load but shows nothing
#
# TODO: fix Vocab.index so it checks for the OWL ways of describing a property.
# this can be done with a filter.
# q= 'SELECT distinct ?x ?l ?c WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a ?type . FILTER (?type = <http://www.w3.org/2002/07/owl#ObjectProperty> || ?type = <http://www.w3.org/2002/07/owl#DatatypeProperty> || ?type = <http://www.w3.org/1999/02/22-rdf-syntax-ns#Property> || ?type = <http://www.w3.org/2002/07/owl#FunctionalProperty> || ?type = <http://www.w3.org/2002/07/owl#InverseFunctionalProperty>) } '



import libvocab
from libvocab import Vocab
from libvocab import Term
from libvocab import Class
from libvocab import Property

from libvocab import SIOC

# Test SIOC spec

fn = 'examples/sioc/sioc.rdf'

spec = Vocab( fn )

spec.uri = SIOC

spec.raw()
spec.index() # slurp info from sources
print spec.report().encode('UTF-8')

for p in spec.properties:
  print "Got a property: " + p
  print p.simple_report().encode('UTF-8')
for c in spec.classes:
  print "Got a class: " + c
  print c.simple_report().encode('UTF-8')
