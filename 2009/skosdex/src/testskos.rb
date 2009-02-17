#!/usr/bin/env jruby 

require 'java'
include Java

require "src/jena_skos"

SKOS.new("http://norman.walsh.name/knows/taxonomy").concepts.each_pair do |k,v|
  puts "SKOS Concept: #{k} prefLabel: #{v.prefLabel}"
end
