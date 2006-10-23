#!/usr/bin/env python
"""Jaspwr : Universal Feed Parser to SPARQL JSON results

Input : any feed (ideally Atom)
Output : as http://www.w3.org/TR/rdf-sparql-json-res/

Uses http://feedparser.org/ 
Mark Pilgrim  (http://diveintomark.org/) et al

Universal Feed Parser Requires: Python 2.1 or later
Recommended: Python 2.3 or later

Blame danbri.
"""

__version__ = "0.1"
__license__ = "take your pick"
__author__ = "Danny Ayers <http://dannyayers.com/>"
__contributors__ = ["Dan Brickley <http://danbri.org/>"]

import sys
import feedparser

class Jaspwr:
    feed_terms = ['id', 'title', 'link', 'subtitle', 'updated']
    entry_terms = ['id', 'title', 'link', 'published', 'updated', 'summary']
    content_terms = ['type', 'base', 'language', 'value']
    uri_terms =  ['id', 'link', 'base']

    result_prefix_separator = "."

    head_prefix = '\n   "head": { \"vars\": [ "'
    head_suffix = '"  ] \n} ,'
    head_separator = '" , "'

    results_prefix = '\n   "results": { "distinct": true , "ordered": false ,'
    results_suffix = '}'

    bindings_prefix = '\n      "bindings": ['
    bindings_separator = '\n} ,\n{\n        '   
    bindings_suffix = '\n]'

    def write(self, feed_data):
        self._json = '{'
        self._write_head(feed_data)
        self._write_results(feed_data)
        self._json = self._json + '}'
        return self._json

    def _write_head(self, feed_data):
        qualified_terms = []
        for term in self.feed_terms:
            qualified_terms.append('feed' + self.result_prefix_separator + term)
        for term in self.entry_terms:
            qualified_terms.append('entry' + self.result_prefix_separator + term)
        for term in self.content_terms:
            qualified_terms.append('entry' + self.result_prefix_separator + 'content' + self.result_prefix_separator + term)
        self._json = self._json + self.head_prefix \
        + self.head_separator.join(qualified_terms) \
        + self.head_suffix

    def _write_results(self, feed_data): 
        self._json = self._json + self.results_prefix 
        self._write_bindings(feed_data)
        self._json = self._json + self.results_suffix

    def _write_bindings(self, feed_data):
        self._json = self._json + self.bindings_prefix
        for i in range(len(feed_data.entries)):
        # feed-level 
            for term in self.feed_terms:
                self._json = self._json + self._get_binding(term, feed_data['feed'], 'feed') + ' ,'
        # entry-level
            for term in self.entry_terms:
                self._json = self._json + self._get_binding(term, feed_data.entries[i], 'entry') + ' ,'
        # content-level        
            for term in self.content_terms:
                try: 
                    for j in range(len(feed_data.entries[i]['content'])):
                       self._json = self._json + self._get_binding(term, feed_data.entries[i]['content'][j], 'entry'+ self.result_prefix_separator+'content') + ' ,'
                except:
                    print "content bleah"
            if i !=  len(feed_data.entries) - 1:               
                self._json = self._json + self.bindings_separator
	# don't know where the last comma might have come from
	    self._json = self._json.rstrip(' ,') 
        self._json = self._json.rstrip(' ,')
        self._json = self._json + self.bindings_suffix

    def _get_binding(self, term, dict, label):
        binding = '\n         "' + label + self.result_prefix_separator + term + '":' \
        + ' { "type": "' 
        if term in self.uri_terms:
            binding = binding + 'uri'
        else:
            binding = binding + 'literal'
	binding = binding + '" , "value": "' 
        # may have missing values or data structures here
        try:
            binding = binding + self.escape(str(dict[term])) 
        except:
            binding = binding + ""
        binding = binding +  '" }'
        return binding

    def escape(self, string):
         string = string.replace('\\', r'\\')
	 string = string.replace('"', r'\"')
	 string = string.replace('\b', r'\b')
	 string = string.replace('\f', r'\f')
	 string = string.replace('\n', r'\n')
	 string = string.replace('\r', r'\r')
	 string = string.replace('\t', r'\t')
         return string

if __name__ == '__main__':
    if not sys.argv[1:]:
        print "\nUsage example :"
        print "python jaspwr.py http://feedparser.org/docs/examples/atom10.xml\n"
        sys.exit(0)
    else:
        d = feedparser.parse(sys.argv[1])
    print Jaspwr().write(d)
