#!/usr/bin/env ruby

require 'rdf/redland'

# egrep '(prefLabel|broader|narrower)' lcsh.nt > tree

uri_string= 'file:tree.nt'
parser_name = 'ntriples'
storage=Redland::TripleStore.new("memory", "test", "new='yes'")
raise "Failed to create RDF storage" if !storage
model=Redland::Model.new(storage)
if !model then
  raise "Failed to create RDF model"
end
parser=Redland::Parser.new(parser_name, "", nil)
if !parser then
  raise "Failed to create RDF parser"
end

uri=Redland::Uri.new(uri_string)
stream=parser.parse_as_stream(uri, uri)

count=0
while !stream.end?()
  statement=stream.current()
  model.add_statement(statement)
  print count 
  print " "
#  puts "found statement: #{statement}"
  count=count+1
  stream.next()
end

puts "Parsing added #{count} statements"

puts "Printing all statements:\n\n"
stream=model.as_stream()
while !stream.end?()
  statement=stream.current()
  puts "Statement: #{statement}"
  # http://www.w3.org/2004/02/skos/core#broader
  stream.next()
end

puts "Done"
