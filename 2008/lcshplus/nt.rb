#!/usr/bin/ruby

require 'rena'
include Rena

filepath='_bristol.nt'
n3_string = File.read(filepath)
parser = N3Parser.new(n3_string)
ntriples = parser.graph.to_ntriples
ntriples.gsub!(/_:bn\d+/, '_:node1')
ntriples = sort_ntriples(ntriples)

