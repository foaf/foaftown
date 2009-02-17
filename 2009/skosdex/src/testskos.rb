#!/usr/bin/env jruby 

require "src/jena_skos"

SKOS.new( "http://norman.walsh.name/knows/taxonomy").read(
	  "http://www.wasab.dk/morten/blog/archives/author/mortenf/skos.rdf").concepts.each_pair do |url,c|

  puts "SKOS Concept: #{url} prefLabel: #{c.prefLabel}"

end
