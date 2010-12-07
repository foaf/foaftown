#!/usr/bin/perl -w

use RDF::RDFa::Parser;
use RDF::Trine;
use constant { TRUE  => 1, FALSE => 0,};

# Note, CPAN installation of the RDF stuff may fail UNLESS you
# install Test::Simple via CPAN first. Known problem with RDF::Trine.

# See also: testing with Redland Raptor parser:
#  e.g. rapper -i rdfa nyt-example.html http://nyt.example.com/people/kelly_slater/

my $arg = shift;
my $file = $arg || "surf3.html";
my $base_uri = "http://example.com/rdfatests#";
my $markup = '';
open(IN,$file) || die "No file to read, $file";
while(<IN>) {$markup .= $_;}
my $p = RDF::RDFa::Parser->new(
	$markup, $base_uri,
	RDF::RDFa::Parser::Config->new( 
		RDF::RDFa::Parser::Config->HOST_XHTML,
		RDF::RDFa::Parser::Config->RDFA_11,
		graph => TRUE,
		graph_type => 'about',
#		graph_attr => "{http://example.com/graphing}graph"
		)
	);
my $g = $p->graphs;

my $turtle = RDF::Trine::Serializer->new('Turtle');

foreach my $n (keys %$g)
{
	print "\n# Graph URI: $n\n";
	print $turtle->serialize_model_to_string($g->{$n});
	print "\n";
}
