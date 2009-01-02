headstream - tracing data streams to their source

Dan Brickley <danbri@danbri.org>, http://danbri.org/

cf. http://en.wikipedia.org/wiki/Source_%28river_or_stream%29

Semantic Web Vapourware

I want a way of taking a flat set of triples (eg. like foaf from http://www.advogato.org/person/connolly/ )
...and saying which come from the party described, and which from the hosting account/provider

Taking the Advogato example:

In http://www.advogato.org/person/connolly/foaf.rdf we have various claims,

ostensibly from dan connolly,
<foaf:PersonalProfileDocument rdf:about="">
<rdfs:label>Advogato FOAF profile for Dan Connolly</rdfs:label>
<foaf:maker rdf:resource="#me"/>
<foaf:primaryTopic rdf:resource="#me"/>
</foaf:PersonalProfileDocument>

...though some of them are backed up by the hosting site, Advogato.

eg. 
<foaf:Person rdf:about="#me">
<foaf:name>Dan Connolly</foaf:name>
<foaf:nick>connolly</foaf:nick>
<foaf:mbox_sha1sum>94b6eb0c835f928c5ed565dc3ed1a355ac1b41e5</foaf:mbox_sha1sum>
<foaf:homepage rdf:resource="http://www.w3.org/People/Connolly/"/>
<foaf:weblog rdf:resource="http://www.advogato.org/person/connolly/diary.html"/>

vs
<foaf:Group rdf:about="http://www.advogato.org/ns/trust#Master">
<foaf:member rdf:resource="#me"/>
</foaf:Group>

vs 
<foaf:knows>
<foaf:Person rdf:about="http://www.advogato.org/person/dajobe/foaf.rdf#me">
<foaf:nick>dajobe</foaf:nick>
<rdfs:seeAlso rdf:resource="http://www.advogato.org/person/dajobe/foaf.rdf"/>
</foaf:Person>
</foaf:knows>

vs
<foaf:currentProject rdf:resource="http://www.advogato.org/proj/SWAP/"/>
<foaf:currentProject rdf:resource="http://www.advogato.org/proj/Daily%20Chump/"/>
<foaf:currentProject rdf:resource="http://www.advogato.org/proj/Zope/"/>
<foaf:currentProject rdf:resource="http://www.advogato.org/proj/Python/"/>

How do these pieces of the graph differ?

1. The document (hosted at advogato) claims to be published on behalf of
the person it describes.
2. It includes some fields that are apparently user-supplied (although the 
mbox_sha1sum is probably machine-generated from a supplied email).
3. It has some 'social graph' data making claims about other people on 
the same site. Not clear if these are verified/reciprocated/checked.
4. It has some 'current project' links, presumably not checked.


Strawman story:

If we make some metadata about SPARQL CONSTRUCT queries against this data, 
we should make it easier for people to associate claims of the form 
"person x is in advogato group y", and be clear that the claims come from the
site. At the moment, claims with various sourcing are all mixed in together 
into a composite data stream. The 'headstream' idea is that we can take the 
smaller source streams and extract them.

Consider a site like Advogato.

Every user has a short accountName, eg. danbri, in http://www.advogato.org/person/connolly/foaf.rdf

this contains lots of data. How can we figure out which bits are the advogato trust ratings? by using a filter that discards everything
we're not interested in. See examples/advogato/ for more details on this scenarios.




The idea is that we define SPARQL-based filters that apply to a file 
eg
 - a music page
 - a social network profile
 - a page about a person, eg. with trust metrics added by host site

Now in many cases, the claims in the page have different sources.

We may want to know which properties/relations are verified/checked.

Example: a site might include email addresses but only if verified, 
or they might require 'friend' stuff to be reciprocated. Or they might 
repost everything a user tells them without any mediation. Or an openid 
could be checked, etc etc.

By writing SPARQL CONSTRUCTs we can turn a flat set of triples into 
smaller streams of data whose provenance/sourcing is more explicit.

This is related to the idea of delegation-based openid+rdfa sites, who 
let a user set up an openid by adding delegation markup, but who add extra
info related to karma such as no. of posts.
 

examples:

bbc music -

http://www.bbc.co.uk/music/artists/0ca53fff-3b07-49eb-bcb9-bbe84f1ec768
http://www.bbc.co.uk/music/artists/0ca53fff-3b07-49eb-bcb9-bbe84f1ec768.rdf


