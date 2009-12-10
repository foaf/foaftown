#!/usr/bin/python
import urllib, simplejson
title = "The Fog of War: Eleven Lessons from the Life of Robert S. McNamara" 
result = simplejson.load(urllib.urlopen("http://ajax.googleapis.com/ajax/services/search/web?%s" % urllib.urlencode({'v': "1.0", 'q': title + " site:imdb.com" })))
print result['responseData']['results'][0]['url']

