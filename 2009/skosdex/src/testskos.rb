#!/usr/bin/env jruby 

require "src/jena_skos"

s1 = SKOS.new()    # ("http://norman.walsh.name/knows/taxonomy")
s1.read("http://www.wasab.dk/morten/blog/archives/author/mortenf/skos.rdf" )
s1.read("file:samples/archives.rdf")
s1.concepts.each_pair do |url,c|
  puts "SKOS: #{url} label: #{c.prefLabel}"
end

c1 = s1.concepts["http://www.ukat.org.uk/thesaurus/concept/1366"] # Agronomy
puts "test concept is "+ c1 + " " + c1.prefLabel
c1.narrower do |uri|
  c2 = s1.concepts[uri]
  puts "\tnarrower: "+ c2 + " " + c2.prefLabel
  c2.narrower do |uri|
    c3 = s1.concepts[uri]
    puts "\t\tnarrower: "+ c3 + " " + c3.prefLabel
  end
end

