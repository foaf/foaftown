#!/usr/bin/env jruby 
#
# export CLASSPATH=:./lib/antlr-2.7.5.jar:./lib/arq-extra.jar:./lib/arq.jar:./lib/commons-logging-1.1.1.jar:./lib/concurrent.jar:./lib/icu4j_3_4.jar:./lib/iri.jar:./lib/jena.jar:./lib/jenatest.jar:./lib/json.jar:./lib/junit.jar:./lib/log4j-1.2.12.jar:./lib/lucene-core-2.2.0.jar:./lib/stax-api-1.0.jar:./lib/wstx-asl-3.0.0.jar:./lib/xercesImpl.jar:./lib/xml-apis.jar:.

# Utility to load SKOS from RDF/XML

dir = "/Users/danbri/working/jena/Jena-2.5.5"

skos_ns = "http://www.w3.org/2004/02/skos/core#"
rdf_ns = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"

require 'java'
include Java
import com.hp.hpl.jena.rdf.model.ModelMaker
import com.hp.hpl.jena.rdf.model.ModelFactory
import com.hp.hpl.jena.rdf.model.Model
import com.hp.hpl.jena.rdf.model.Property
import com.hp.hpl.jena.rdf.model.RDFNode
import com.hp.hpl.jena.rdf.model.Literal
import com.hp.hpl.jena.rdf.model.SimpleSelector
import com.hp.hpl.jena.vocabulary.RDF
import com.hp.hpl.jena.util.FileManager

#import com.hp.hpl.jena.query
import com.hp.hpl.jena.query.larq.IndexBuilderString
import com.hp.hpl.jena.query.larq.IndexLARQ
import com.hp.hpl.jena.query.larq.LARQ
import com.hp.hpl.jena.sparql.util.StringUtils
import com.hp.hpl.jena.sparql.util.Utils

import com.hp.hpl.jena.query.QueryFactory
import com.hp.hpl.jena.query.QueryExecutionFactory


############## Simple SKOS Object Model ######################################

class SKOS
  attr_accessor :concepts, :skosdb, :skos_ns, :larq

  def initialize( fn = nil, dir='.', c = {} )
    self.concepts = c
    # puts "SKOS fn is #{ fn }"
    @skos_ns = "http://www.w3.org/2004/02/skos/core#"
    @rdf_ns = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    if (fn != nil)
      puts "Loading from file #{fn} "
      self.read(fn)
    end
  end

  def read(data = "file:default.rdf")
    puts("Reading from #{data}")
    puts "Data string is: #{data} "
    m = FileManager.get().loadModel( data ) 
    # puts("Model is #{m}")
    self.readModel(m)
    return(self)
  end

  # experiment. not working.
  def larqdex(datafile = "./tmp/larq")
     puts "Making a larq index for #{datafile} "
     larqBuilder = IndexBuilderString.new
     larqBuilder.indexStatements(@skosdb.listStatements()) 
     larqBuilder.closeWriter() 
     @larq = larqBuilder.getIndex()
    
  end

  def readModel(jenamodel = com.hp.hpl.jena.rdf.model.ModelFactory.createFileModelMaker('.').openModel('skos.rdf',true) )
    self.skosdb = jenamodel
    self.load()
    return(self)
  end

  def load()
    skos_concept = skosdb.createProperty(skos_ns, "Concept");
    skos_broader = skosdb.createProperty(skos_ns, "broader" );
    skos_narrower = skosdb.createProperty(skos_ns, "narrower" );
    skos_prefLabel = skosdb.createProperty(skos_ns, "prefLabel");
    concepts = skosdb.listStatements( SimpleSelector.new(nil, RDF.type, skos_concept ) )
#    puts "Scanning concepts... #{concepts} with #{skos_concept} type, skos_ns = #{skos_ns}"
    while (concepts.hasNext()) 
     print "*"
     c = concepts.nextStatement().getSubject()
     l = c.getProperty(skos_prefLabel)
     if (l != nil)
       l = l.getLiteral()
     end
     con = Concept.new(c, l, self)
     self.concepts[ c.to_s ] = con
    end
  end
end

class Concept

  attr_accessor :prefLabel, :broader, :narrower, :uri, :scheme

  def initialize(c, prefLabel="", m = nil)
    self.uri = c
    self.prefLabel = prefLabel.to_s
    self.scheme = m
  end 

  def to_s
    return self.uri.to_s
  end

  def to_str
    return self.uri.to_s
  end

  def narrower(&code)
    rel("narrower",&code)
  end

  def broader(&code)
    rel("broader", &code)
  end

  def rel(rel, &code)
    me = @uri
    qs = "SELECT * WHERE { <#{me}> <http://www.w3.org/2004/02/skos/core#"+rel+"> ?y }"
#    puts "Query: #{qs} against model: #{@model}"
    res = []
    query = QueryFactory.create(qs)
    qexec = QueryExecutionFactory.create(query, @scheme.skosdb)
    begin
      results = qexec.execSelect()
      while (results.hasNext())
        res.push(results.nextSolution().get("y").to_s)
      end
    rescue
      puts "Saved! "+ $!
    end
    if (code != nil)   
      res.each do |y|
	c = scheme.concepts[y]
        puts "Concept in scheme #{scheme} is : "+c
	# todo. we get a nil here sometimes... 
        code.call(y)
      end
    else
      return res
    end
  end

end

