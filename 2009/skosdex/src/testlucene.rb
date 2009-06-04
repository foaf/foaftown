#!/usr/bin/env jruby 

# Loads SKOS thesaurus into a Lucene index
#
# Lucene APIs

require "src/jena_skos"

require 'java'
include Java

import org.apache.lucene.analysis.Analyzer
import org.apache.lucene.analysis.standard.StandardAnalyzer
import org.apache.lucene.document.Document
import org.apache.lucene.document.Field
import org.apache.lucene.index.IndexWriter
import org.apache.lucene.store.FSDirectory
import org.apache.lucene.index

class SKOSIndexer

  attr_accessor :skos

  def initialize(skos=nil)
    self.skos = skos
    puts( "Building index to store SKOS data " + skos.class.to_s)
  end

  def index(indexDir=".")
    puts "Indexing. indexDir is #{indexDir}"
	# see http://lucene.apache.org/java/2_4_0/api/org/apache/lucene/index/IndexWriter.html#DEFAULT_MAX_FIELD_LENGTH
	# http://www.markwatson.com/blog/2007/06/using-lucene-with-jruby.html
    directory = FSDirectory.getDirectory(indexDir)
    index_available = org.apache.lucene.index.IndexReader.index_exists(directory)
    writer = org.apache.lucene.index.IndexWriter.new( directory,
          	org.apache.lucene.analysis.standard.StandardAnalyzer.new, !index_available)
    writer.setUseCompoundFile(true)		# why?

    skos.concepts.each_key do |k|
      c = skos.concepts[k]
      puts "Indexing #{c.prefLabel} - #{c} "
      g = c.prefLabel # hmm
      doc =  Document.new()
      g.gsub!(/@[A-Za-z]+/,'')  # trim lang tag from raw prefLabel (todo: push into SKOS api)
      doc.add( Field.new( "word", g, org.apache.lucene.document.Field::Store::YES, org.apache.lucene.document.Field::Index::TOKENIZED))
				# todo, what is Field.Index.NOT_ANALYZED
      doc.add( Field.new( "uri", c.to_s, org.apache.lucene.document.Field::Store::YES, org.apache.lucene.document.Field::Index::TOKENIZED))
				# todo, what is Field.Index.NOT_ANALYZED
      # todo: altLabel
      # todo: nearby weight-able labels from related concepts
      writer.addDocument(doc)
    end
    writer.optimize()
    writer.close()
  end
end

#thes = SKOS.new("http://norman.walsh.name/knows/taxonomy")

#thes = SKOS.new("http://www.wasab.dk/morten/blog/archives/author/mortenf/skos.rdf")

#thes = SKOS.new("file:samples/nofarsi.xml")
#thes = SKOS.new("file:samples/lcsh.nt")
thes = SKOS.new("file:samples/ukat/ukatconcepts.rdf")

thes.concepts.each_key do |r|
  puts "# Concept: #{r}"
  u = thes.concepts[r]  
   u.prefLabel.each do |l|
     puts "# prefLabel: '#{l}' "
   end
   u.prop "# altLabel" do |x|
    puts "\t# alt label "+x
  end
  puts "\n"
end


#sx = SKOSIndexer.new(thes)
#sx.index("./tmp")


 		                # don't store things like 'pit bull' -> 'american pit bull'
				#			doc.add( Field.new( F_SYN, cur, Field.Store.YES, Field.Index.NO));
