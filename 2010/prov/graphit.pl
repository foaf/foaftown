#!/usr/bin/perl -w

use RDF::RDFa::Parser;
use RDF::Trine;
use constant { TRUE  => 1, FALSE => 0,};

my $url = "file:surf2.html";
my $p = RDF::RDFa::Parser->new_from_url(
	$url,
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
