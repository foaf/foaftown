#!/usr/bin/ruby

require "rubygems"
require "sparql_client"
require "sparql_results"
require "json"

# Simple REST client for SPARQL protocol
# Status: unfinished transliteration of Pythong original. XML/JSON detail 
# to be pushed down into library code.          danbrickley@gmail.com

qs = "SELECT DISTINCT ?name ?url WHERE {  [ <http://xmlns.com/foaf/0.1/name> ?name ; <http://xmlns.com/foaf/0.1/homepage> ?url ]  }"
endpoint = "http://sandbox.foaf-project.org/2008/foaf/ggg.php"

format = SPARQL::JSON  # note: sandbox ARC server is truncating string values
# format = SPARQL::XML

sparql = SPARQL::SPARQLWrapper.new(endpoint)
#sparql.addDefaultGraph("http://danbri.org/foaf.rdf")
sparql.setQuery(qs)
puts "Query string: \n" + qs + "\n\n"
begin
    sparql.setReturnFormat(format)
    ret = sparql.query()

    case format
        when SPARQL::XML
            puts "Results: #{ret._convertXML().class}"    
            doc=ret._convertXML() 
            puts doc.each_element('//result') {|row|  
	           puts "ROW: "+ row.to_s 
            }
        when SPARQL::JSON
           data = JSON.parse(ret.response)
           data["results"]["bindings"].each do |row|
               puts "Name: "+ row["name"]["value"] + "\t" + row["url"]["value"] 
           end
       else
            raise "Unknown format"
     end
rescue
   puts "It all went horribly wrong: #{$!}"
end

