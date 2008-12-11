This is an experimental new codebase for specgen tools.

Inputs: RDF, HTML and OWL description(s) of an RDF vocabulary
Output: an XHTML+RDFa specification designed for human users

See libvocab.py and specgen5.py for details. --danbri

"What it does":

The last FOAF spec was built using http://xmlns.com/foaf/0.1/specgen.py
This reads an index.rdf, a template.html file plus a set of per-term files, 
eg. 'doc/homepage.en' etc., then generates the main HTML FOAF spec.

Announcement: 
http://lists.foaf-project.org/pipermail/foaf-dev/2008-December/009415.html
http://groups.google.com/group/sioc-dev/browse_thread/thread/36190062d384624d

See also: http://forge.morfeo-project.org/wiki_en/index.php/SpecGen (another rewrite)
http://crschmidt.net/semweb/redland/

Goals:

 - be usable at least for (re)-generating the FOAF spec and similar
 - work well with multi-lingual labels 
 - be based on SPARQL queries against RDFS/OWL vocab descriptions
 - evolve a Python library that supports such tasks
 - keep vocab-specific hackery in scripts that call the library
 - push display logic into CSS
 - use a modern, pure Python RDF library for support

Status:

 - we load up and interpret the core RDFS/OWL 
 - we populate Vocab, Term (Class or Property) instances
 - we have *no* code yet for generating HTML spec

TODO:

 - mine the old implementations to understand what we need to know 
about each class and property.
 - decide how much of OWL we want to represent
 - see what rdflib itself might offer to help with all this

ISSUES

1. librdf doesn't seem to like abbreviations in FILTER clauses.
this worked:

q= 'SELECT ?x ?l ?c ?type WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a ?type .  FILTER (?type = <http://www.w3.org/2002/07/owl#ObjectProperty>)  } '

while this failed:

q= 'PREFIX owl: <http://www.w3.org/2002/07/owl#> SELECT ?x ?l ?c ?type WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a ?type .  FILTER (?type = owl:ObjectProperty)  } '

(even when passing in bindings)

This forces us to be verbose, ie.
q= 'SELECT distinct ?x ?l ?c WHERE { ?x rdfs:label ?l . ?x rdfs:comment ?c . ?x a ?type . FILTER (?type = <http://www.w3.org/2002/07/owl#ObjectProperty> || ?type = <http://www.w3.org/2002/07/owl#DatatypeProperty> || ?type = <http://www.w3.org/1999/02/22-rdf-syntax-ns#Property> || ?type = <http://www.w3.org/2002/07/owl#FunctionalProperty> || ?type = <http://www.w3.org/2002/07/owl#InverseFunctionalProperty>) } '


2. Figure out the best way to do tests in Python. assert()? read diveinto...

3. TODO: work out how to do ".encode('UTF-8')" everywhere

4. Be more explicit and careful re defaulting to English, and more robust when
multilingual labels are found.


5. Currently, queries find nothing in SIOC. We need to match various OWL 
and RDF ways of saying "this is a property", and encapsulate this in a 
function. And test it. SIOC should find 20<x<100 properties, etc.