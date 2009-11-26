#!/bin/sh

# this assumes template.html in main dir, and drops a _tmp... file into that dir as a candidate index.html
# also assumes http://svn.foaf-project.org/foaf/trunk/xmlns.com/ checked out in parallel filetree

./specgen5.py --indir=../../xmlns.com/htdocs/foaf/ \
--ns=http://xmlns.com/foaf/0.1/ \
--prefix=foaf \
--templatedir=../../xmlns.com/htdocs/foaf/spec/ \
--indexrdfdir=../../xmlns.com/htdocs/foaf/spec/ \
--outdir=../../xmlns.com/htdocs/foaf/spec/ 
