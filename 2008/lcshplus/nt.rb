#!/usr/bin/ruby

require 'rena'
include Rena

r=File.new('lcsh.rdf').read

p = RdfXmlParser.new(r)
puts p
graph = p.graph
puts    graph.is_rdf?
puts    graph.size 
#    print graph.graph.to_ntriples
