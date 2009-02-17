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

############## Simple SKOS Object Model ######################################

class SKOS
  attr_accessor :concepts, :skosdb, :skos_ns

  def initialize( fn = nil, dir='.', c = {} )
    self.concepts = c
    # puts "SKOS fn is #{ fn }"
    @skos_ns = "http://www.w3.org/2004/02/skos/core#"
    @rdf_ns = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"

    if (fn != nil)
      puts "Loading from file #{fn} in dir #{dir} "
      self.read(fn,dir)
    end
  end

  def read(fn = "default.rdf", dir=".")
    puts("Reading from #{fn} in #{dir}")
    m = ModelFactory.createFileModelMaker(dir).openModel(fn,true)  
#    puts("Model is #{m}")
    self.readModel(m)
    return(self)
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
     b = c.getProperty(skos_broader)
     if (b != nil) 
       b = b.getResource
     end
     n = c.getProperty(skos_narrower)
     if (n.class != NilClass) 
       n= n.getResource
     end
#     puts "Concept: #{c} label: #{l} b: #{b} n: #{n} "
     con = Concept.new(l, b, n)
     self.concepts[ c.to_s ] = con
    end
  end
end

class Concept
  attr_accessor :prefLabel, :broader, :narrower
  def initialize(prefLabel="", broader = [], narrower = [] )
#    puts "Init concept... #{prefLabel}"
    self.prefLabel = prefLabel
  end 
end

################################################################################

dir = './samples/'
#arch_thes = SKOS.new("mini.rdf", dir).concepts.each_pair do |k,v|
#  puts "ARCH Concept: #{k} prefLabel: #{v.prefLabel}"
#end

#dir = "./samples/"
#thb_thes = SKOS.new( 'THBOntology.owl' ,dir).concepts.each_pair do |k,v|
#  puts "ARCH Concept: #{k} prefLabel: #{v.prefLabel}"
#end

ukat = "ukat_concepts.rdf"
dir = "./samples/ukat"
dir = "./samples"
puts "UKAT IS #{ukat} in #{dir}"
arch_thes = SKOS.new( ukat ,dir).concepts.each_pair do |k,v|
  puts "ARCH Concept: #{k} prefLabel: #{v.prefLabel}"
end

#thb_thes = SKOS.new("thb-test.rdf",dir).concepts.each_pair do |k,v|
#  puts "ARCH Concept: #{k} prefLabel: #{v.prefLabel}"
#end

#thb_thes = SKOS.new("nofarsi.xml",dir).concepts.each_pair do |k,v|
#  puts "ARCH Concept: #{k} prefLabel: #{v.prefLabel}"
#end


# docs:
#
# file:///Users/danbri/working/jena/Jena-2.5.5/doc/javadoc/com/hp/hpl/jena/rdf/model/StmtIterator.html
# 
#import java.util.Iterator
#import com.hp.hpl.jena.rdf.model.impl.Util
