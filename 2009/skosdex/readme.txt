
This is Ruby software designed to run in Jruby. 

It uses Jena, a Java-based RDF toolkit.

$JRUBY_HOME must be set, and included on the $PATH so we have the jruby script executable.

everthing in lib/ must be on the CLASSPATH

http://dist.codehaus.org/jruby/

Everything else should just work. Jena library is in lib/

Dan Brickley <danbri@danbri.org>




The idea here is to have a lightweight OO API for SKOS, couched in terms of a network
of linked "Concepts", with broader and narrower relations. But this is backed by a full
RDF API (in our case Jena, via Java jruby magic). Eventually, entire apps could be built at 
the SKOS API level. For now, anything beyond broader/narrower and prefLabel is hidden away
in the RDF. 

The API design uses Ruby closures, so you can call "narrower" on some concept and that 
code will get called back for each matching concept, if any. For now the block is only 
passed a concept URI, perhaps this will change.

Example code:


	s1 = SKOS.new()
	s1.read("file:samples/archives.rdf")

	c1 = s1.concepts["http://www.ukat.org.uk/thesaurus/concept/1366"] # Agronomy
	puts "test concept is "+ c1 + " " + c1.prefLabel
	c1.narrower do |uri|
	  c2 = s1.concepts[uri]
	  puts "\tnarrower: "+ c2 + " " + c2.prefLabel
	  c2.narrower do |uri|
	    c3 = s1.concepts[uri]
	    puts "\t\tnarrower: "+ c3 + " " + c3.prefLabel
	  end
	end


test concept is http://www.ukat.org.uk/thesaurus/concept/1366 Agronomy
	narrower: http://www.ukat.org.uk/thesaurus/concept/1333 Pest control
		narrower: http://www.ukat.org.uk/thesaurus/concept/21558 Spraying (pesticides)
		narrower: http://www.ukat.org.uk/thesaurus/concept/21037 Herbicide use
		narrower: http://www.ukat.org.uk/thesaurus/concept/3038 Insect control
		narrower: http://www.ukat.org.uk/thesaurus/concept/21677 Weedkiller use
		narrower: http://www.ukat.org.uk/thesaurus/concept/21098 Insecticide use
		narrower: http://www.ukat.org.uk/thesaurus/concept/20978 Fungicide use
		narrower: http://www.ukat.org.uk/thesaurus/concept/21323 Pesticide use
		narrower: http://www.ukat.org.uk/thesaurus/concept/21509 Sheep dipping
		narrower: http://www.ukat.org.uk/thesaurus/concept/21447 Rodent control
		narrower: http://www.ukat.org.uk/thesaurus/concept/4527 Pests
	narrower: http://www.ukat.org.uk/thesaurus/concept/6063 Horticulture
		narrower: http://www.ukat.org.uk/thesaurus/concept/16896 Viticulture
		narrower: http://www.ukat.org.uk/thesaurus/concept/13685 Nurseries (Horticulture)
		narrower: http://www.ukat.org.uk/thesaurus/concept/15902 Fruit growing
		narrower: http://www.ukat.org.uk/thesaurus/concept/12048 Arboriculture
	narrower: http://www.ukat.org.uk/thesaurus/concept/4216 Weed control
	narrower: http://www.ukat.org.uk/thesaurus/concept/2509 Cultivation
		narrower: http://www.ukat.org.uk/thesaurus/concept/4635 Dry farming
		narrower: http://www.ukat.org.uk/thesaurus/concept/2523 Food production
		narrower: http://www.ukat.org.uk/thesaurus/concept/5563 Shifting cultivation
		narrower: http://www.ukat.org.uk/thesaurus/concept/2641 Harvesting
		narrower: http://www.ukat.org.uk/thesaurus/concept/16680 Seed growing
		narrower: http://www.ukat.org.uk/thesaurus/concept/16360 Osier growing
		narrower: http://www.ukat.org.uk/thesaurus/concept/12697 Cotton growing
		narrower: http://www.ukat.org.uk/thesaurus/concept/16008 Hop growing

