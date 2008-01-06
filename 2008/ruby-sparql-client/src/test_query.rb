#!/usr/bin/ruby

require "rubygems"
require "sparql_client"
require "sparql_results"
require "json"

qs = "SELECT DISTINCT ?name ?url WHERE {  [ <http://xmlns.com/foaf/0.1/name> ?name ; <http://xmlns.com/foaf/0.1/homepage> ?url ]  }"
endpoint = "http://sandbox.foaf-project.org/2008/foaf/ggg.php"

sparql = SPARQL::SPARQLWrapper.new(endpoint)
#sparql.addDefaultGraph("http://danbri.org/foaf.rdf")
sparql.setQuery(qs)
puts "Query string: \n" + qs + "\n\n"
begin
    sparql.setReturnFormat(SPARQL::JSON)
    ret = sparql.query()
    # puts "Results: #{ret.response}"    
    data = JSON.parse(ret.response)
    data["results"]["bindings"].each do |row|
      puts "Name: "+ row["name"]["value"] + "\t" + row["url"]["value"] 
    end
rescue
   puts "It all went horribly wrong: #{$!}"
end

