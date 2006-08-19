#!/usr/bin/perl

use Mail::Box::Mbox;
use Data::Dumper;
use rdfize;

my $folder = Mail::Box::Mbox->new(folder => 'test-files/august-mails.mbox');
#my $folder = Mail::Box::Mbox->new(folder => 'test-files/2006-August.txt');

my @messages = $folder->messages;

my @rdfbuf;

push @rdfbuf, '<rdf:RDF '.
	'xmlns:dc="http://purl.org/dc/elements/1.1/" '.
	'xmlns:foaf="http://xmlns.com/foaf/0.1/" '.
	'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"'.
	'>';

foreach my $msg (@messages) {
	push @rdfbuf, rdfize($msg);
}

push @rdfbuf, "</rdf:RDF>\n\n";

print join "\n", @rdfbuf;



