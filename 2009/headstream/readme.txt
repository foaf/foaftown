headstream - tracing data streams to their source

cf. http://en.wikipedia.org/wiki/Source_%28river_or_stream%29

Semantic Web Vapourware

but the idea is that we define SPARQL-based filters that apply to a file 
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


