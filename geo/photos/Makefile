all:	clean fpretty.xml

clean:
	rm -f api-flickr.xml
	rm -f f.xml
	rm -f fpretty.xml

api-flickr.xml:
	curl "http://api.flickr.com/services/rest/?min_taken_date=1970-01-01%2000:00:00&bbox=-180,-90,180,90&method=flickr.photos.search&name=value&api_key=dc4a78d5a8fb4d22266376de58ab61fd&group_id=43935391225@N01&extras=license,date_upload,date_taken,owner_name,icon_server,original_format,last_update,geo&per_page=500" > api-flickr.xml


f.xml:	api-flickr.xml
	xsltproc flickr-sparqlxml.xsl api-flickr.xml > f.xml


fpretty.xml:	f.xml
	xsltproc pretty-xml.xsl f.xml > fpretty.xml


