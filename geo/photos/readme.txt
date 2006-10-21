
Old notes, out of date...



That old photos-on-maps thing.

Flickr

We can grab geo-tagged data from Flickr (Aaron Straup Cope is investigating some 
bugs tho), using their REST API, or his Net::Flickr::Backup and Net::Flickr::API, 
Net::Flickr::RDF Perl CPAN libraries. The latter are meant for backing up a person's 
data and hence use the authentication system. But it should be adaptable to "back 
up" the images and more interestingly the metadata for a specified Flickr group. 
Alternatively, using the REST API, we can do this with just an application key, eg:

http://api.flickr.com/services/rest/?min_taken_date=1970-01-01%2000:00:00&bbox=-180,-90,180,90&method=flickr.photos.search&name=value&api_key=xxxxxxxxxxxxxxx&group_id=43935391225@N01&extras=license,date_upload,date_taken,owner_name,icon_server,original_format,last_update,geo&per_page=500

Here that is again, with a bid of prettyprinting:

http://api.flickr.com/services/rest/?
		min_taken_date = 1970-01-01%2000:00:00
	&	bbox = -180,-90,180,90
	&	method = flickr.photos.search
	& 	name = value 
	&	api_key = xxxxxxxxxxxxxxx
	&	group_id = 43935391225@N01
	&	extras = license,date_upload,date_taken,owner_name,icon_server,original_format,last_update,geo
	&	per_page = 500

 
Notes from Aaron:

geo queries require a "limiting" agent. This is similar, in scope, to not allowing parameterless queries in a non-geo 
context. Limiting agents are tags, min_date_update, min_date_upload, etc. Anyway, if no limiting agent is passed we assign a 
default restriction of photos uploaded in the last 12 hours. We will probably 
increase that limit and/or just throw an error depending on which makes the most sense.
At any rate, the group id should also be treated as a limiting agent so I will fix that...

DanBri suggested this might be usefully representing as SPARQL resultset XML format.

Danny Ayers made a first pass at that, see files in this directory.

Next steps: consume the SPARQL XML with a toolkit (eg. Perl).

Notes from Danny:

	first pass attached, plus an xml prettifier that comes in handy
	xsltproc flickr-sparqlxml.xsl api-flickr.xml > f.xml
	xsltproc pretty-xml.xsl f.xml > fpretty.xml
	Doesn't do anything with the attributes of these:
	<rsp stat="ok">
	<photos page="1" pages="1" perpage="250" total="39" 

$Id$
$Log$
