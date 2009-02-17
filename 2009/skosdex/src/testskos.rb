#!/usr/bin/env jruby 

require 'java'
include Java
import com.hp.hpl.jena.query.QueryFactory
import com.hp.hpl.jena.query.QueryExecutionFactory

require "src/jena_skos"

#s1 = SKOS.new( "http://norman.walsh.name/knows/taxonomy")
s1 = SKOS.new()
s1.read( "http://www.wasab.dk/morten/blog/archives/author/mortenf/skos.rdf" ).concepts.each_pair do |url,c|
  puts "SKOS: #{url} label: #{c.prefLabel}"
end

c41 = s1.concepts["http://www.wasab.dk/morten/blog/archives/author/mortenf/skos.rdf#c41"]

puts "C41 is "+c41.to_s

puts "C41 has broader: "+c41.broader.to_s

