#!/bin/sh

# this assumes template.html in main dir, and drops a _tmp... file into that dir as a candidate index.html
# also assumes http://svn.foaf-project.org/foaf/trunk/xmlns.com/ checked out in parallel filetree

export XMLCOM=../xmlns.com
# XMLCOM../../foaf/trunk/xmlns.com

./specgen5.py --indir=$XMLCOM/htdocs/foaf/ \
--ns=http://xmlns.com/foaf/0.1/ \
--prefix=foaf \
--templatedir=$XMLCOM/htdocs/foaf/spec/ \
--indexrdfdir=$XMLCOM/htdocs/foaf/spec/ \
--outfile=20100726.html \
--outdir=$XMLCOM/htdocs/foaf/spec/ 


#--outfile=_live_editors_edition.html \

# TODO: can we say exactly which infile we want. useful while editing 20100101.rdf for eg, so index remains untouched until pub
