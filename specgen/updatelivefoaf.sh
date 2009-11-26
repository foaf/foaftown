#!/bin/sh

# this assumes template.html in main dir, and drops a _tmp... file into that dir as a candidate index.html
# also assumes http://svn.foaf-project.org/foaf/trunk/xmlns.com/ checked out in parallel filetree

./specgen5.py ../../xmlns.com/htdocs/foaf/spec/ http://xmlns.com/foaf/0.1/ foaf 
