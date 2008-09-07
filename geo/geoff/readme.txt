Geo Friend Finder?

Inspired by a note from Mike Liebhold to the GeoWankers list.

This downloads the gzipped archives from mailman.


First grab the archive:

	mkdir -p data
	ruby getraw.rb > log1.txt
	ls data
	cd data; gunzip *gz


Then in our top-level dir, we poke around the data:

	ruby mail2group.rb > log2.txt


What we might do next:

For each email address (and/or its hash), poke around in Google's 
Social Graph API to find other account URI associated with that party.

We could do this pre-stats, to normalise our count so that danbri@danbri.org,
danbri@w3.org and danbri@rdfweb.org get counted against the same person.

See http://danbri.org/words/2008/02/05/267
http://socialgraph.apis.google.com/otherme?q=danbri.org
http://danbri.org/words/2008/02/09/271 
http://groups.google.com/group/social-graph-api/browse_thread/thread/d5fc1f26ac5da56a




From http://danbri.org/words/2008/02/09/271

danbrickley@gmail.com -> 
sgn://mboxsha1/?pk=6e80d02de4cb3376605a34976e31188bb16180d0

http://socialgraph.apis.google.com/otherme?pretty=1&q=sgn%3A%2F%2Fmboxsha1%2F%3Fpk%3D6e80d02de4cb3376605a34976e31188bb16180d0

which is 
http://socialgraph.apis.google.com/otherme?pretty=1&q=sgn%3A%2F%2Fmboxsha1%2F%3Fpk%3D
+
6e80d02de4cb3376605a34976e31188bb16180d0


Where the latter comes from generating an mbox_sha1sum id:
>> require 'digest/sha1'
=> true
>> Digest::SHA1.hexdigest('mailto:danbrickley@gmail.com')
=> "6e80d02de4cb3376605a34976e31188bb16180d0"



Without this normalisation each sender email gets a separate count,  

Airbag:geoff danbri$ grep -i danbri log2.txt 
20: 	danbri@danbri.org 
15: 	danbri@w3.org 

... people's contribution count could be truncated.

Here, my count is too low, showing that the ugly regex parsing of the mail
archive files isn't working well enough yet.

Ideas for development:

1. Normalise all emails by calling sgapi, so we get a better total posts
 contrib per person.

2. Take the n% top posters
  (of course this could get fancier, and do more analytics that take into 
   account engagement/discussion rather than simply poster count; replying 
   point-by-point to 10 mails shows more engagement than posting 20 
   conference CFPs. On the other hand, analytics showing who is ignored 
   are a bit much: we can't do too much of this without affecting the 
   occupants of  the goldfish bowl. So I stick with post-count for now.

3. Take all their HTTP URIs from Google Social Graph API,
    - extract blogs, twitter, rss feeds
    - extract mugshot/icon urls
    
4. But what to do with it?
  - See whether the buddylist data from SGAPI is any good
  - Generate a 'planet geoff' config file to aggregate blog, twitter etc
    from this community
  - something to do with maps

