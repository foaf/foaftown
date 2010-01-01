#!/bin/sh

# this assumes template.html in main dir, and drops a _tmp... file into that dir as a candidate index.html
# also assumes http://svn.foaf-project.org/foaf/trunk/xmlns.com/ checked out in parallel filetree

./specgen5.py --indir=../../foaf/trunk/xmlns.com/htdocs/foaf/ \
--ns=http://xmlns.com/foaf/0.1/ \
--prefix=foaf \
--templatedir=../../foaf/trunk/xmlns.com/htdocs/foaf/spec/ \
--indexrdfdir=../../foaf/trunk/xmlns.com/htdocs/foaf/spec/ \
--outfile=20100101.html \
--outdir=../../foaf/trunk/xmlns.com/htdocs/foaf/spec/ 


#--outfile=_live_editors_edition.html \

# TODO: can we say exactly which infile we want. useful while editing 20100101.rdf for eg, so index remains untouched until pub
