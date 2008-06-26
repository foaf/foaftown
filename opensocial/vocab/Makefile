all:	rdfa rdfxml check

rdfa:
	sh extractOpensocial.sh > _latest.html

rdfxml:
	curl --silent "http://www.w3.org/2007/08/pyRdfa/extract?uri=http%3A%2F%2Fdanbri.org%2F2008%2Fopensocial%2F_latest.html&format=pretty-xml&warnings=false&parser=lax&space-preserve=true&submit=Go!" > _latest.rdf

check:	rdfa rdfxml
	rapper --count _latest.rdf

getjs:
	svn co http://opensocial-resources.googlecode.com/svn/spec/0.8/opensocial/
