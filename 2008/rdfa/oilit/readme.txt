
Notes on an Oil industry case study.

cleaned like 
tidy -bare -clean -numeric -utf8 -asxml src/2com.htm > new/2com-tidy.html
tidy -bare -clean -numeric -utf8 -asxml src/2pro.htm > new/2pro-tidy.html

then rdfa-ized partly by hand

then eg
    ./rdfaize.rb 2com-rdfa.html > 2com-rdfa-plus.html 

   rapper -i rdfa file:2pro-rdfa-plus.html -o rdfxml > 2pro.rdf
   rapper -i rdfa file:2com-rdfa-plus.html -o rdfxml > 2com.rdf


roqet -e 'select ?s ?p ?o FROM <file:2com.rdf> FROM <file:2pro.rdf> WHERE { ?s ?p ?o } '


Dan Brickley <http://danbri.org/>


Files from Nil McNaughton at Oil IT.
how to
> 'semantify' my website - so that its metadata is 'discoverable'. This means
> (I guess), exposing our lists of companies, products etc. in RDF. They are
> currently stored as lists of links to collections of articles. Relevant
> files are (for example)
> http://www.oilit.com/2journal/2index/2com.htm 
> and 
> http://www.oilit.com/2journal/2index/2pro.htm 

> What I'd like is the following ...
> 1) For the site something that says 'the companies in this list are involved
> in oil and gas' - like a namespace that makes it clear that 'Apache' is an
> oil company, not an Indian.

> 2) A proper, semantic format (SKOS?) for my company, product lists...
> 3) A way of pointing to a company in a meaningful way from my text - showing
> that 'Apache' is in my list of companies as above.
> 4) A way of pointing out from the SKOS file to a) the groups of articles as
> above and b) to a single (XML/OWL?) file per company with more information
> about the company.
> 
> I seem to have made it all seem very complicated. But the question is/should
> be, simple - how do you house a list of things on a website so that they can
> be discovered from the outside in a controlled way (namespace?) and
> embellished on the site with more information (XML/OWL?)



> Editor, Oil IT Journal (www.oilit.com)
>  
> Visit www.oilit.com/tech for sample Technology Watch reports from major
> industry conferences and tradeshows.
> In an independent 2005 survey by Houston-based Spur Digital, www.oilit.com
> was found to be the "Top Website for Energy IT Professionals". 



roqet -e 'select ?name from <file:2peo-tidy-plus.html> WHERE { ?x <http://xmlns.com/foaf/0.1/name> ?name  FILTER REGEX (?name, "^Dan", "i") } '

