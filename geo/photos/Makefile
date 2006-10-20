#FLICKR_API_KEY=dc4a7XXXXXXXX
# set this here or in your environment vars, .bashrc etc

# Main thing: choose a group by uncommenting the GROUP_ID line

# GROUP_ID=52240190192@N01
# Iranians http://www.flickr.com/groups/iranian/pool/map

GROUP_ID=43935391225@N01
# Buenos Aires
 
#GROUP_ID=46594087@N00
# http://www.flickr.com/groups/bristol/pool/map

URI=http://api.flickr.com/services/rest/?min_taken_date=1970-01-01%2000:00:00&bbox=-180,-90,180,90&method=flickr.photos.search&name=value&api_key=$(FLICKR_API_KEY)&group_id=$(GROUP_ID)&extras=license,date_upload,date_taken,owner_name,icon_server,original_format,last_update,geo&per_page=500


all:	clean _f.js _fpretty.xml earth

earth:
	ruby pics2ge.rb > _pics.kml

clean:
	rm -f _api-flickr.xml
	rm -f f.xml
	rm -f fpretty.xml
	rm -f _f.js
	rm -f _pics.kml

_api-flickr.xml:

	curl "$(URI)" > _api-flickr.xml

_f.xml:	_api-flickr.xml
	xsltproc flickr-sparqlxml.xsl _api-flickr.xml > _f.xml


_fpretty.xml:	_f.xml
	xsltproc pretty-xml.xsl _f.xml > _fpretty.xml

_f.js:	_api-flickr.xml
	xsltproc flickr-sparqljson.xsl _api-flickr.xml > _f.js

