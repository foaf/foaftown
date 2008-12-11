This is an experimental new codebase for specgen tools.

Inputs: RDF, HTML and OWL description(s) of an RDF vocabulary
Output: an XHTML+RDFa specification designed for human users

See libvocab.py and specgen5.py for details. --danbri

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

