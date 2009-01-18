#!/usr/bin/perl 
# 
# RDFize Gedcom data. Uses CPAN module by Brian Cassidy, see 
# http://www.genealogyforum.com/gedcom/gedr2090.htm for sample data.
# http://search.cpan.org/dist/Gedcom-FOAF/lib/Gedcom/FOAF.pm for docs.
# 
# This little script just repackages the output into a larger dump file. 
#
# Dan Brickley <http://danbri.org/> danbri@danbri.org, January 2009.
#
# Usage: perl gedcom2foafdump.pl BUELL001.GED > _sample_gedfoaf.rdf

use Gedcom;
use Gedcom::FOAF;
my $f = shift || die "No file specified.";
my $gedcom = Gedcom->new( gedcom_file => $f );
my @individuals = $gedcom->individuals;

print '<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" ';
print ' xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" ';
print ' xmlns:rel="http://purl.org/vocab/relationship/" ';
print ' xmlns:foaf="http://xmlns.com/foaf/0.1/" ';
print ' xmlns:bio="http://purl.org/vocab/bio/0.1/">';
print "\n";

foreach my $i (@individuals) {
  my $xml =  $i->as_foaf;
  $xml =~ s!<\?xml([^?]+)\?>!\n!g;
  $xml =~ s!<rdf:RDF\s+([^>]*)>!!g;
  $xml =~ s!</rdf:RDF>!\n!g;
  chomp($xml);
  print $xml;
}
print "</rdf:RDF>\n";
