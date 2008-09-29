#!/bin/sh

#roqet  -r json -e 'select distinct ?x ?y ?z from <file:_rels.nt> where { ?x <http://purl.org/dc/terms/relation> ?y . ?z <http://purl.org/dc/terms/relation> ?x . filter( ?x != ?y) . } '

roqet -r json stats.rq
